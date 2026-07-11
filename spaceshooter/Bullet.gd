extends Area2D

export var speed = 600

func _process(delta):
	position.y -= speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
