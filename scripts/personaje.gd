extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -320.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var bullet = preload("res://scenes/bullet.tscn")

# Variable para duración de animación de disparo
var shoot_timer: float = 0.0

# Variable para el tiempo de recarga entre disparos
var shoot_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	# Solo se dispara si el cooldown ha terminado
	if Input.is_action_just_pressed("disparar") and shoot_cooldown <= 0:
		animated_sprite_2d.play("disparar")
		shoot_timer = 0.30
		# Reinicia el cooldow. Solo se puede disparar una bala cada 3 segundos
		shoot_cooldown = 0.75
		var bullet_temp = bullet.instantiate()
		# Asignar la dirección de la bala según donde mira el personaje
		if animated_sprite_2d.flip_h:
			bullet_temp.direction = -1
		else:
			bullet_temp.direction = 1
		# Se instancia en la escena principal para que la bala sea independiente del personaje
		get_tree().current_scene.add_child(bullet_temp)
		# Ajustar la posición inicial de la bala para que salga frente al personaje
		bullet_temp.global_position = global_position + Vector2(35 * bullet_temp.direction, 0)
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Cambiar la dirección del sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	# Activar animaciones
	# Se termina la animación de disparar y después se cambia a otra
	if shoot_timer > 0:
		animated_sprite_2d.play("disparar")
	else:
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jump")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
