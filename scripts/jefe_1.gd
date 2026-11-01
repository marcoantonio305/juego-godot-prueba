extends CharacterBody2D


var vida:int = 12

@export var velocidad_normal: float = 120.0
@export var velocidad_dash: float = 500.0

@export var limite_izquierdo: float = 100.0
@export var limite_derecho: float = 800.0

@onready var timer_decisiones: Timer = $Timer
@onready var bala_enemiga = preload("res://scenes/bala-enemiga.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum Estado {IDLE, PERSEGUIR, DASH, DISPARAR, MOVER_A_PUNTO}
var estado_actual: Estado = Estado. IDLE
var direccion_x: float = 0.0
var objetivo_x: float = 0.0
var jugador: Personaje = null
var preparando_dash = false


func _ready()-> void:
	# Buscar al jugador mediante su tipo "Personaje" o por el grupo "jugador"
	_buscar_jugador()
	add_to_group("jefes")
	
	#Configurar el timer para cambiar de acción cada 1.2 segundos
	timer_decisiones.wait_time = 1.2
	timer_decisiones.timeout.connect(_elegir_accion_aleatoria)
	timer_decisiones.start()
	
func _physics_process(delta: float) -> void:
	# Si pierde la referencia del jugador, (por ejemplo, al morir) la busca de nuevo
	if not is_instance_valid(jugador):
		_buscar_jugador()
	
	#Se queda en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match estado_actual:
		Estado.IDLE:
			velocity.x = move_toward(velocity.x, 0, velocidad_normal)
			animated_sprite_2d.play("default")
		
		Estado.PERSEGUIR:
			if is_instance_valid(jugador):
				#Obtiene solo si el jugador está a la izquierda o derecha
				direccion_x = sign(jugador.global_position.x - global_position.x)
			velocity.x = direccion_x * velocidad_normal
			animated_sprite_2d.play("run")
		
		Estado.MOVER_A_PUNTO:
			direccion_x = sign(objetivo_x - global_position.x)
			velocity.x = direccion_x * velocidad_normal
			animated_sprite_2d.play("run")
			
			# Si llega al punto objetivo, finaliza el movimiento
			if abs(global_position.x - objetivo_x) < 10.0:
				estado_actual = Estado.IDLE
		
		Estado.DASH:
			if preparando_dash:
				velocity.x = 0
				animated_sprite_2d.play("before_dash")
			else:
				velocity.x = direccion_x * velocidad_dash
				animated_sprite_2d.play("dash")
		
		Estado.DISPARAR:
			animated_sprite_2d.play("shoot")
			velocity.x = 0
	
	_actualizar_orientacion_sprite()
	move_and_slide()
	_comprobar_contacto_jugador()
	
	#Si choca contra una pared mientras se mueve o hace un dash, finaliza la acción
	if is_on_wall():
		if estado_actual == Estado.MOVER_A_PUNTO or estado_actual == Estado.DASH:
			estado_actual = Estado.IDLE

func _buscar_jugador()->void:
	var nodo = get_tree().get_first_node_in_group("jugador")
	if nodo is Personaje:
		jugador = nodo
	else:
		for child in get_tree().current_scene.get_children():
			if child is Personaje:
				jugador = child
				break

#Daño por contacto
func _comprobar_contacto_jugador()-> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Personaje:
			if collider.has_method("defeat"):
				collider.defeat()

func _elegir_accion_aleatoria()->void:
	if not is_instance_valid(jugador) or estado_actual == Estado.DASH or estado_actual == Estado.DISPARAR:
		return
	
	var opcion:int = randi() % 4
	
	match opcion:
		0:
			estado_actual = Estado.PERSEGUIR
		1:
			_mover_a_zona_escenario()
		2:
			_iniciar_dash()
		3:
			_disparar()

func _mover_a_zona_escenario()->void:
	estado_actual = Estado.MOVER_A_PUNTO
	var zonas = [limite_izquierdo, (limite_izquierdo + limite_derecho) / 2.0, limite_derecho]
	objetivo_x = zonas[randi() % zonas.size()]
	
func _iniciar_dash()->void:
	estado_actual = Estado.DASH
	preparando_dash = true
	if is_instance_valid(jugador):
		direccion_x = sign(jugador.global_position.x - global_position.x)
		if direccion_x == 0:
			direccion_x = -1.0 if animated_sprite_2d.flip_h else 1.0
	#Muestra before dash, estando quieto durante 0.5s
	await get_tree().create_timer(0.6).timeout
	preparando_dash = false
	await get_tree().create_timer(0.4).timeout
	if estado_actual == Estado.DASH:
		estado_actual = Estado.IDLE

func _disparar()->void:
	estado_actual = Estado.DISPARAR
	velocity.x = 0
	animated_sprite_2d.play("shoot")
	
	#Espera 0.5 segundo antes de dispara para que el jugador pues esquivarlo
	await get_tree().create_timer(0.5).timeout
	
	if estado_actual == Estado.DISPARAR and bala_enemiga and is_instance_valid(jugador):
		var proyectil = bala_enemiga.instantiate()
		
		if jugador.global_position.x < global_position.x:
			proyectil.direction = -1
		else:
			proyectil.direction = 1
		
		get_tree().current_scene.add_child(proyectil)
		proyectil.global_position = global_position + Vector2(30 * proyectil.direction, 0)
			
	await get_tree().create_timer(0.5).timeout
	estado_actual = Estado.IDLE
			

func _actualizar_orientacion_sprite()->void:
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif is_instance_valid(jugador):
		#Si está parado, mira hacia donde está el jugador
		animated_sprite_2d.flip_h = (jugador.global_position.x < global_position.x)

func _on_area_contacto_body_entered(body: Node2D)-> void:
	#Si toca al personaje
	if body is Personaje:
		if body.has_method("defeat"):
			body.defeat()

func recibir_dano(cantidad: int=1)->void:
	#Si ya está en el proceso de morir, ignora cualquier bala adicional
	if vida <= 0:
		return
	print("El jefe recibió daño. Vida restante: ", vida)
	vida -= cantidad
	
	
	if vida <= 0:
		# Desactivar decisiones y físicas para bloquear actualizaciones de animación
		set_physics_process(false)
		timer_decisiones.stop()
		#Desactiva movimiento y colisión para que no reciba más balas ni empuje al jugador al morir
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		#Restaura el color normal y reproduce la animacion de muerte
		modulate = Color.WHITE
		animated_sprite_2d.play("death")
		#Esperar que finalice la animación de muerte antes de eliminar el nodo
		await get_tree().create_timer(3.0).timeout
		queue_free()
	else:
		#Parpadeo rojo visual rápido de 0.25 segundos sin alterar alterar animaciones
		modulate = Color.RED
		await get_tree().create_timer(0.25).timeout
		modulate = Color.WHITE
