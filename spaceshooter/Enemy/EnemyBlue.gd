extends "res://Enemy/Enemy.gd"
var time = 0
var start_y
var offset = 0

export var wave_height = 120
export var wave_speed = 2
export var horizontal_speed = 120

func _ready():
	randomize()

	offset = rand_range(0,10)

	velocity.x = Utils.choice_list([
		horizontal_speed,
		-horizontal_speed
	])
	start_y = position.y + 200

func _physics_process(delta):

	time += delta

	position.x += velocity.x * delta

	position.y = start_y + sin((time + offset) * wave_speed) * wave_height

	rotation = sin(time * 3 + offset) * 0.1


	if position.x <= 64:
		velocity.x = abs(velocity.x)

	if position.x >= Utils.view_size.x - 64:
		velocity.x = -abs(velocity.x)

func _on_EnemyBlue_area_entered(area):

	_on_Enemy_area_entered(area)
