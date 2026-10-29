extends Area2D

var speed = 200

var direction:int = 1

var duration: float = 3.5

func _process(delta: float) -> void:
	#Si falta algún dato, se sale del fotograma sin romper el juego
	if not speed or not direction:
		return
	position.x += speed * direction * delta
	duration -= delta
	if duration <= 0:
		queue_free()

# Se activa cuando la bala choca con el jugador o el mapa
func _on_body_entered(body: Node2D)-> void:
	#Si toca al personaje
	if body is Personaje:
		if body.has_method("defeat"):
			body.defeat()
			#Desactiva la bala para que no siga haciendo daño ni se vea una vez choca
		hide()
		set_deferred("monitoring", false)
	else:
		#Se destruya la bala si choca con algo que no es el jugador
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited()-> void:
	queue_free()
		

	
