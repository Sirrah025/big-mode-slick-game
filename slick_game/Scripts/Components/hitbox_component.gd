extends Area3D

signal change_speed(speed_change: float)
signal damage(damage: int)
@export var damage_audio: AudioStreamPlayer

# Pass attack data to other parts of the player scene
func _emit_hit_box_signal(attack_data: AttackData) -> void:
	change_speed.emit(attack_data.speed_change)
	damage.emit(attack_data.health_damage)
	if damage_audio:
		damage_audio.play_random_audio()

# Grab attack_data from the damaging area
func _on_body_entered(body: Node3D) -> void:
	_emit_hit_box_signal(body.attack_data)

# Grab attack_data from the damaging area
func _on_area_entered(area: Area3D) -> void:
	_emit_hit_box_signal(area.attack_data)
