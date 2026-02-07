extends Button

@export var next_scene: PackedScene


func _on_start_game_pressed() -> void:
	LoadScenes.start_game(next_scene)


func _on_settings_pressed() -> void:
	LoadScenes.change_to_settings()


func _on_back_to_menu_pressed() -> void:
	LoadScenes.change_to_main_menu()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	LoadScenes.change_to_credits()
