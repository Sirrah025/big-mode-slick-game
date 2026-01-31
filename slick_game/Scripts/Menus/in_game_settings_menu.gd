extends Control


signal close_settings


func _on_back_to_pause_menu_pressed() -> void:
	close_settings.emit()
