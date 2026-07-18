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


func toggle_pause():
	get_tree().paused = not get_tree().paused
	var overlay = $CanvasLayer.get_node_or_null("PauseOverlay")
	if get_tree().paused:
		if not overlay:
			_create_pause_overlay()
	else:
		if overlay:
			overlay.queue_free()


func _create_pause_overlay():
	var overlay = ColorRect.new()
	overlay.name = "PauseOverlay"
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.pause_mode = Node.PAUSE_MODE_PROCESS
	overlay.anchor_left = 0
	overlay.anchor_right = 1
	overlay.anchor_top = 0
	overlay.anchor_bottom = 1
	$CanvasLayer.add_child(overlay)

	var vbox = VBoxContainer.new()
	vbox.pause_mode = Node.PAUSE_MODE_PROCESS
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	overlay.add_child(vbox)

	var label = Label.new()
	label.text = "- PAUSA -"
	label.align = Label.ALIGN_CENTER
	label.pause_mode = Node.PAUSE_MODE_PROCESS
	vbox.add_child(label)

	var btn_continue = Button.new()
	btn_continue.text = "CONTINUAR"
	btn_continue.pause_mode = Node.PAUSE_MODE_PROCESS
	vbox.add_child(btn_continue)
	btn_continue.connect("pressed", self, "toggle_pause")

	var btn_quit = Button.new()
	btn_quit.text = "SALIR AL MENU"
	btn_quit.pause_mode = Node.PAUSE_MODE_PROCESS
	vbox.add_child(btn_quit)
	btn_quit.connect("pressed", self, "_on_Salir_menu_pressed")
		

func _on_Salir_pressed():
	get_tree().change_scene("res://main/Control.tscn")

func _on_SALIR_pressed():
	get_tree().change_scene("res://main/Control.tscn")
