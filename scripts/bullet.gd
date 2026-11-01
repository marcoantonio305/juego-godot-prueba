extends Area2D

var speed = 200

var direction = 1

var duration: float = 3.5

@onready var enemy_defeat_sfx: AudioStreamPlayer = $enemy_defeat_sfx

func _process(delta: float) -> void:
	position.x += speed * direction * delta
	duration -= delta
	if duration <= 0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos") or area.get_parent().is_in_group("enemigos"):
		var enemigo = area.get_parent()
		if enemigo.has_method("desaparecer"):
			# Esto se hace para sacar el sonido de la bala y meterla en la escena principal 
			#porque sino al desaparecer la bala también desaparece el sonido
			enemy_defeat_sfx.reparent(get_tree().current_scene)
			enemy_defeat_sfx.play(0.3)
			enemigo.desaparecer()
		queue_free() # La bala desaparece cuando choca con el enemigo

func _on_body_entered(body:Node2D)->void:
	if body.is_in_group("jefes") or body.get_parent().is_in_group("jefes"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(1)
		queue_free()
