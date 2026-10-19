extends Area2D

var speed = 200

var direction = 1

func _process(delta: float) -> void:
	position.x += speed * direction * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos") or area.get_parent().is_in_group("enemigos"):
		area.get_parent().queue_free() #Borra el enemigo
		queue_free() # La bala desaparece cuando choca con el enemigo
