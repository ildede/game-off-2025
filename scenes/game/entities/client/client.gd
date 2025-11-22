extends Node2D
class_name Client

const task_scene = preload("res://scenes/game/entities/task/task.tscn")

var client_id = 0;
var path_to_translator: Path2D
var translator: Node2D

func initialize(my_position: Vector2, translator_position: Vector2, client_data: Dictionary):
	self.position = my_position
	client_id = randi()
	var curve = Curve2D.new()
	curve.add_point($Sprite.position)
	curve.add_point(translator_position - my_position)
	var path = Path2D.new()
	path.curve = curve
	path_to_translator = path
	add_child(path_to_translator)
	$Name.text = client_data.get("name", "Cliente")
	$Timer.wait_time = client_data.get("task_interval", 1.0)

func _on_timer_timeout() -> void:
	var task = task_scene.instantiate()
	path_to_translator.add_child(task)
	Global.client_send_task.emit(task)
