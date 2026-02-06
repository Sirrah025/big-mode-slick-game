extends AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ready_weapons():
	set("parameters/StateMachine/playback", "At Ready")


func _on_fire_weapons():
	set("parameters/StateMachine/playback", "Fire")
