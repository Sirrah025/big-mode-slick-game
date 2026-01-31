extends VBoxContainer



func _on_headbob_check_button_toggled(toggled_on: bool) -> void:
	Settings.head_bob_enabled = toggled_on
