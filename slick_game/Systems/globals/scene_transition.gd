extends CanvasLayer

func _ready():
	fade_out()

func fade_in() -> void:
	$AnimationPlayer.play("Fade In")
	await $AnimationPlayer.animation_finished

func fade_out() -> void:
	$AnimationPlayer.play("Fade Out")
	await $AnimationPlayer.animation_finished

func fade_in_red() -> void:
	$AnimationPlayer.play("Fade In Red")
	await $AnimationPlayer.animation_finished

func fade_out_red() -> void:
	$AnimationPlayer.play("Fade Out Red")
	await $AnimationPlayer.animation_finished
