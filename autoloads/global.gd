extends Node

signal client_send_task
signal letter_hit_task
signal update_reputation
signal update_stress
signal update_quality
signal update_money

func _ready() -> void:
	print("Global ready")
