extends Control

@onready var pause_menu_container := $Container
@onready var button_container := $"Container/Button Container"
@onready var settings := $"Container/Settings Menu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause") and !get_tree().paused:
		get_tree().paused = true
		pause_menu_container.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	elif Input.is_action_just_pressed("Pause") and get_tree().paused:
		get_tree().paused = false
		pause_menu_container.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_menu_container.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_button_pressed() -> void:
	settings.visible = true
	button_container.visible = false


func _on_main_menu_button_pressed() -> void:
	LoadScenes.change_to_main_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_menu_close_settings() -> void:
	settings.visible = false
	button_container.visible = true
