extends Node2D

const SPEED = 100

var direction = 1

var derrotado: bool = false # controla si el enemigo fue derrotado

#Distancia píxeles que recorre de izquierda para derecha
var distance = 50

var start_x: float

@onready var killzone: Area2D = $killzone
@onready var ray_cast_left: RayCast2D = $killzone/RayCastLeft
@onready var ray_cast_right: RayCast2D = $killzone/RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Se añade al grupo "enemigos"
	add_to_group("enemigos")
	start_x = position.x
	animated_sprite_2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Detiene el movimiento si muere el enemigo
	if derrotado:
		return
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = false
	elif ray_cast_right.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = true

	if position.x >= start_x + distance:
		direction = -1
		animated_sprite_2d.flip_h = false
	elif position.x <= start_x - distance:
		direction = 1
		animated_sprite_2d.flip_h = true
		
	position.x += direction * SPEED * delta
	
	

func _on_killzone_area_entered(area: Area2D) -> void:
	if "hace_dano_enemigos" in area and area.hace_dano_enemigos: # Verifica si chocó con una bala
		desaparecer()
		
func desaparecer()->void:
	if derrotado:
		return
	derrotado = true
	
	#Desactiva las colisiones
	killzone.set_deferred("monitoring", false)
	killzone.set_deferred("monitorable", false)
	
	animated_sprite_2d.play("defeat")
	
	#Espera que la animacion de derrota acabe antes de eliminar el nodo de animación
	await animated_sprite_2d.animation_finished
	queue_free()
