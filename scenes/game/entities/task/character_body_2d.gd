extends CharacterBody2D
class_name TaskBody

var task_id = 0;

func _ready() -> void:
	task_id = randi()
	$Sprite2D.play("default")
