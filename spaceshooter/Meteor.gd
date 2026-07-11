extends Area2D

export var speed = 250

func _physics_process(delta):
	position.y += speed * delta
	if position.y > Utils.view_size.y + 50:
		queue_free()

func _on_Meteor_area_entered(area):
	if area.is_in_group("bullet"):
		area.queue_free()
		if get_parent().has_method("add_score"):
			get_parent().add_score(50)
		_spawn_explosion()
		queue_free()

func _spawn_explosion():
	var explosion = preload("res://sprites/Explosion.tscn").instance()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
