extends AnimationTree


func _on_ready_weapons():
	get("parameters/StateMachine/playback").travel("Ready Fire")


func _on_fire_weapons():
	get("parameters/StateMachine/playback").travel("Fire")
