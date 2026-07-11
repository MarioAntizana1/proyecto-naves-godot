extends Node

export (PackedScene) var Meteor

func _ready():
	while true:
		spawn()
		yield(get_tree().create_timer(1.0), "timeout")

func spawn():
	var m = Meteor.instance()
	get_parent().add_child(m)

	m.position = Vector2(rand_range(0, 1024), -50)
