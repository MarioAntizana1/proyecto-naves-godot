extends Control
func _ready():
	pass # Replace with function body.

func _on_Salir_pressed():
	get_tree().change_scene("res://main/Control.tscn")


func _on_Siguiente_pressed():
	if Globals.current_stage == 1:

		Globals.current_stage = 2

		get_tree().change_scene("res://stage/Stage2.tscn")


	elif Globals.current_stage == 2:

		Globals.current_stage = 3

		get_tree().change_scene("res://stage/Stage3.tscn")


