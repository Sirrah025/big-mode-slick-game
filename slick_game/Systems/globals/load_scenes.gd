class_name loadScenes
extends Node

@onready var settings_menu = preload("res://Scenes/Menus/before_game_settings_menu.tscn")
@onready var main_menu = preload("res://Scenes/Menus/main_menu.tscn")
@onready var main_scene = preload("res://Scenes/Levels/main_level.tscn")

func change_to_settings():
	get_tree().change_scene_to_file("res://Scenes/Menus/settings_menu.tscn")

func change_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func start_game(scene: PackedScene):
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Levels/main_level.tscn")
	
	get_tree().paused = false
