extends Node

export (PackedScene) var Meteor

func _ready():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self, "spawn")

func spawn():
	var m = Meteor.instance()
	get_parent().add_child(m)
	m.position = Vector2(rand_range(0, 1024), -50)
