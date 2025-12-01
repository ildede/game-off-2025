extends Area2D
class_name Letter

var speed = 200
var possible_letters = ["A","B","C","D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var target: PathFollow2D
var target_id: int
var word_count: int = 10
var quality_vector: Vector2

func _ready() -> void:
	$Sprite2D.play(possible_letters.pick_random())
	word_count = Config.WORDS_PER_LETTER
	quality_vector = Vector2(randi_range(0, 3), randi_range(-1, 1)) * (160 - Global.game_state.quality*1.5)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		#global_position = global_position.move_toward(target.global_position + Vector2(randi_range(-500, 500), randi_range(-500, 500)), speed * delta) <-- EFFETTO UBRIACO
		global_position = global_position.move_toward(target.global_position + quality_vector, speed * delta)
		if abs(global_position.length() - (target.global_position + quality_vector).length()) <= 10:
			queue_free()
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is TaskBody:
		if body.task_id == target_id:
			Global.letter_hit_task.emit(self, body.get_parent())
			Global.update_quality.emit(0.1)
