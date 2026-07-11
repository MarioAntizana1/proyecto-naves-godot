extends Control

func _on_Back_pressed():
	get_tree().change_scene("res://main/Control.tscn")


func _on_Nivel_1_pressed():
	get_tree().change_scene("res://stage/Stage.tscn")


func _on_Nivel_2_pressed():
	get_tree().change_scene("res://stage/Stage2.tscn")


func _on_Nivel_3_pressed():
	get_tree().change_scene("res://stage/Stage3.tscn")
