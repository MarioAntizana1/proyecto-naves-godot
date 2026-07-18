extends Node

export(bool) var spawn_blue = true
export(bool) var spawn_red = true

export(int) var max_enemies = 50

var enemies_spawned = 0

const BLUE = preload("res://Enemy/EnemyBlue.tscn")
const RED = preload("res://Enemy/EnemyRed.tscn")

var enemies = []

func _ready():

	if spawn_blue:
		enemies.append(BLUE)

	if spawn_red:
		enemies.append(RED)

	print("Spawner iniciado")
	$SpawnTimer.start()


func spawn():

	if enemies_spawned >= max_enemies:
		$SpawnTimer.stop()
		return

	if enemies.empty():
		return

	var enemy = Utils.choice_list(enemies).instance()

	var pos = Vector2()
	pos.x = rand_range(64, Utils.view_size.x - 64)
	pos.y = -64

	enemy.position = pos

	get_parent().add_child(enemy)

	enemies_spawned += 1

	$SpawnTimer.wait_time = rand_range(0.5, 2.0)
	$SpawnTimer.start()

func _on_SpawnerTimer_timeout():
	spawn()
