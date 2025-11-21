extends Node

signal client_send_task
signal letter_hit_task
signal update_reputation
signal update_stress
signal update_quality

func _ready() -> void:
	print("Global ready")
