extends "res://Enemy/Enemy.gd"

func _ready():
	velocity = Vector2(0, rand_range(250, 1000))

func _on_EnemyRed_area_entered(area):
	_on_Enemy_area_entered(area)
