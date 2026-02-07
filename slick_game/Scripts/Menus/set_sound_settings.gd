extends VBoxContainer

func _ready():
	$"HBoxContainer/Master Slider".value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$"HBoxContainer2/Music Slider".value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$"HBoxContainer3/SFX Slider".value = db_to_linear(AudioServer.get_bus_volume_db(2))



func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
