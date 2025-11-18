extends Node2D

@export var task_scene: PackedScene

signal new_task(task: PackedScene)

var client_id = 0;
var path_to_translator: Path2D
var translator: Node2D

func _ready() -> void:
	client_id = randi()
	var curve = Curve2D.new()
	curve.add_point($Sprite.position)
	curve.add_point(translator.global_position - $Sprite.global_position)
	var path = Path2D.new()
	path.curve = curve
	path_to_translator = path
	add_child(path_to_translator)

func _on_timer_timeout() -> void:
	var task = task_scene.instantiate()
	path_to_translator.add_child(task)
	new_task.emit(task)
