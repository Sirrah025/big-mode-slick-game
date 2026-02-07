extends Control

@onready var screen = $Screen
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	screen.visible = true
	animation_player.play("Failed")
	#GlobalSignals.connect("Player_Dies", _show_death_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _show_death_screen() -> void:
	get_tree().paused = true
	screen.visible = true
	animation_player.play("Failed")


func _on_restart_pressed() -> void:
	LoadScenes.start_game(null)


func _on_menu_pressed() -> void:
	LoadScenes.change_to_main_menu()


func _on_quit_pressed() -> void:
	get_tree().quit()
