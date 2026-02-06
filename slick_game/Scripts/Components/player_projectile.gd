extends Node3D

var speed = 90.0
var damage = 30.0

func _physics_process(delta):
	global_position += -transform.basis.z * speed * delta

func _on_despawn_timeout() -> void:
	queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	queue_free()
	if body.is_in_group("Enemy"):
		body.change_health(-damage)
