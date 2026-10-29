extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	if body is Personaje:
		if body.has_method("defeat"):
			body.defeat()


#func _on_timer_timeout() -> void:
#	Engine.time_scale = 1.0
#	get_tree().reload_current_scene()
