class_name loadScenes
extends Node

@onready var settings_menu = preload("res://Scenes/before_game_settings_menu.tscn")
@onready var main_menu = preload("res://Scenes/main_menu.tscn")

func change_to_settings():
	get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")

func change_to_main_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func start_game(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
