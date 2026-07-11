extends Control



func _on_Play_pressed():
	get_tree().change_scene("res://stage/Stage.tscn")


func _on_Option_pressed():
	get_tree().change_scene("res://main/options.tscn")


func _on_Quit_pressed():
	get_tree().quit()
