extends Node2D

const SPEED = 100

var direction = 1

var derrotado: bool = false # controla si el enemigo fue derrotado

#Distancia píxeles que recorre de arriba para abajo
var distance = 50

var start_y: float

@onready var killzone: Area2D = $killzone
@onready var ray_cast_up: RayCast2D = $killzone/RayCastUp
@onready var ray_cast_down: RayCast2D = $killzone/RayCastDown
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Se añade al grupo "enemigos"
	add_to_group("enemigos")
	start_y = position.y
	animated_sprite_2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Detiene el movimiento si muere el enemigo
	if derrotado:
		return
	if ray_cast_down.is_colliding():
		direction = -1
	elif ray_cast_up.is_colliding():
		direction = 1

	if position.y >= start_y + distance:
		direction = -1
	elif position.y <= start_y - distance:
		direction = 1
		
	position.y += direction * SPEED * delta
	
	

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
