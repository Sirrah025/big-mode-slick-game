extends Node3D

@onready var pause_menu = $"UI/Pause Menu"
@onready var death_screen = $"UI/Death Screen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_menu.visible = false
	death_screen.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
