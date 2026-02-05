extends Node


@onready var MusicPlayer := $MusicPlayer


func set_music(BGM: AudioStreamMP3):
	MusicPlayer.stream = BGM
	MusicPlayer.play(0.0)
