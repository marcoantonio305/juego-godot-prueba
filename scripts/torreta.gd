extends StaticBody2D

@onready var bala_enemiga = preload("res://scenes/bala-enemiga.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var tiempo_disparo: float = 0.0
@export var intervalo_disparo: float = 2.5

func _ready()->void:
	#Señal para cuando temina una animación
	if not animated_sprite_2d.animation_finished.is_connected(_on_animation_finished):
		animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
	#Animación por defecto
	animated_sprite_2d.play("default")
	
func _physics_process(delta: float) -> void:
	tiempo_disparo += delta
	
	if tiempo_disparo >= intervalo_disparo:
		tiempo_disparo = 0.0
		disparar()

func disparar()->void:
	animated_sprite_2d.play("shoot")
	
	var bala = bala_enemiga.instantiate()
	
	if animated_sprite_2d.flip_h:
		bala.direction = 1
	else:
		bala.direction = -1
	
	get_tree().current_scene.add_child(bala)
	bala.global_position = global_position
	
	
	

func _on_animation_finished()->void:
	if animated_sprite_2d.animation == "shoot":
		animated_sprite_2d.play("default")
