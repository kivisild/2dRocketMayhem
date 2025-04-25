extends Node2D



func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")
