extends AudioStreamPlayer3D

@export var audio: Array[AudioStreamMP3]

@export var truncate_audio = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if truncate_audio and playing:
		await get_tree().create_timer(1.0).timeout
		stop()


func play_random_audio() -> void:
	if !playing:
		var random_audio = randi_range(0, len(audio)-1)
		stream = random_audio
		play()
