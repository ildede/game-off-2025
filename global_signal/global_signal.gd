extends Node

signal client_send_task
signal letter_hit_task
signal update_reputation
signal update_stress
signal update_quality

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("global_receiver ready")
