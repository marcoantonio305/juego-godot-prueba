extends Node2D

const SPEED = 100

var direction = 1

#Distancia píxeles que recorre de arriba para abajo
var distance = 50

var start_y: float


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
		queue_free()
