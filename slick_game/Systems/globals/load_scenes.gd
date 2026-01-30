class_name loadScenes
extends Node


@onready var settings_menu = get_tree().root.get_child(3).get_child(1)
@onready var main_menu = get_tree().root.get_child(3).get_child(0)

func show_settings():
	settings_menu.visible = true
	main_menu.visible = false

func hide_settings():
	settings_menu.visible = false
	main_menu.visible = true

func start_game(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
