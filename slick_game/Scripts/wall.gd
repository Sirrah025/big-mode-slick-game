extends StaticBody3D

@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape3D
var opened = false


func _ready() -> void:
	animation_player.play("RESET")
	opened = false
	collision.disabled = false

func close() -> void:
	if opened:
		animation_player.play("Slide_In")
		collision.disabled = false
		opened = false

func open() -> void:
	if !opened:
		animation_player.play("Slide_Out")
		collision.disabled = true
		opened = true
