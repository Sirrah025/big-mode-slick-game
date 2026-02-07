class_name loadScenes
extends Node


func change_to_settings():
	SceneTransition.fade_in()
	get_tree().change_scene_to_file("res://Scenes/Menus/settings_menu.tscn")
	SceneTransition.fade_out()

func change_to_main_menu():
	SceneTransition.fade_in()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	SceneTransition.fade_out()

func change_to_credits():
	SceneTransition.fade_in()
	get_tree().change_scene_to_file("res://Scenes/Menus/credits.tscn")
	SceneTransition.fade_out()

func change_to_death():
	SceneTransition.fade_in_red()
	get_tree().change_scene_to_file("res://Scenes/Menus/death_screen.tscn")
	SceneTransition.fade_out_red()

func start_game(scene: PackedScene):
	SceneTransition.fade_in()
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Levels/main_level_f.tscn")
	SceneTransition.fade_out()
	
	get_tree().paused = false
