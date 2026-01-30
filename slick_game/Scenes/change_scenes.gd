extends Control



# Separate function for all related transition logic
func change_scene(scene: PackedScene):
	print(get_tree().change_scene_to_packed(scene))


func _transition_to_scene(scene: PackedScene) -> void:
	change_scene(scene)


func _on_settings_transition_to_scene(scene: PackedScene) -> void:
	pass
