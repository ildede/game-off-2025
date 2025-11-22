extends Area2D
class_name Letter

var speed = 200
var possible_letters = ["A","B","C","D"]
var target: PathFollow2D
var target_id: int
var word_count: int = 10

func _ready() -> void:
	var imported_resource = load("res://scenes/game/entities/letter/assets/{0}.png".format([possible_letters.pick_random()]))
	$Sprite2D.texture = imported_resource

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.move_toward(target.global_position, speed * delta)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is TaskBody:
		if body.task_id == target_id:
			Global.letter_hit_task.emit(self, body.get_parent())
