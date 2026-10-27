extends Area2D

var speed = 200

var direction = 1

func _process(delta: float) -> void:
	position.x += speed * direction * delta

# Se activa cuando la bala choca con el jugador o el mapa
func _on_body_entered(body: Node2D)-> void:
	#Si toca al personaje
	if body is Personaje:
		Engine.time_scale = 0.5
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").queue_free()
			#Desactiva la bala para que no siga haciendo daño ni se vea una vez choca
		hide()
		set_deferred("monitoring", false)
		
		await get_tree().create_time(0.3).timeout
		Engine.time_scale = 10.0
		get_tree().reload_current_scene()
	else:
		#Se destruya la bala si choca con algo que no es el jugador
		queue_free()

func on_visible_on_screen_notifier_2d_screen_exited()-> void:
	queue_free()
		

	
