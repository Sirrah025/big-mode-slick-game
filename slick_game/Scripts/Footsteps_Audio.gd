extends AudioStreamPlayer

@export var audio: Array[AudioStreamMP3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_random_audio() -> void:
	if !playing:
		var random_audio = randi_range(0, len(audio)-1)
		stream = random_audio
		play()
