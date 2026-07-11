	extends Node

#==========================
# VARIABLES DEL JUEGO
#==========================
var score = 0
var level = 1
var enemies_destroyed = 0
var enemies_total = 50
#==========================
# HUD
#==========================
onready var score_label = $CanvasLayer/ScoreLabel
onready var level_label = $CanvasLayer/LevelLabel
onready var enemy_counter = $CanvasLayer/EnemyCounter

func _ready():

	$Player.position = $PlayerPosition.global_position

	$CanvasLayer/GameOver.visible = false

	update_ui()
	update_enemy_counter()


#==========================
# ACTUALIZAR HUD
#==========================
func update_ui():

	# Siempre muestra 4 dígitos
	score_label.text = "%04d" % score

	level_label.text = str(level)
	
func update_enemy_counter():

	enemy_counter.text = str(enemies_destroyed) + "/" + str(enemies_total)


#==========================
# SUMAR PUNTOS
#==========================
func add_score(points):

	score += points
	enemies_destroyed += 1

	check_level()

	update_ui()
	update_enemy_counter()
	if enemies_destroyed >= enemies_total:
		get_tree().change_scene("res://completed/DefenseCompleted.tscn")


#==========================
# COMPROBAR NIVEL
#==========================
func check_level():

	if score >= 3000:
		level = 3

	elif score >= 1000:
		level = 2

	else:
		level = 1

	apply_level()


#==========================
# APLICAR DIFICULTAD
#==========================
func apply_level():

	match level:

		1:
			$SpawnerEnemy/SpawnTimer.wait_time = 2.0

		2:
			$SpawnerEnemy/SpawnTimer.wait_time = 1.2

		3:
			$SpawnerEnemy/SpawnTimer.wait_time = 0.6


#==========================
# GAME OVER
#==========================
func _on_Salir_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://main/Control.tscn")

func _on_continuar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func game_over():

	$CanvasLayer/GameOver.visible = true
	$SoungGameOver.play()

	get_tree().paused = true
		

func _on_Salir_pressed():
	get_tree().change_scene("res://main/Control.tscn")

func _on_SALIR_pressed():
	get_tree().change_scene("res://main/Control.tscn")
