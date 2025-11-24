extends Node2D
class_name Client

const task_scene = preload("res://scenes/game/entities/task/task.tscn")

var client_id = 0;
var path_to_translator: Path2D
var translator: Node2D
var daily_words: int = 0
var payment_per_word: float = 0

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
	daily_words = client_data.get("daily_words", 1)
	payment_per_word = client_data.get("payment_per_word", 0.01)
	_on_timer_timeout()
	#$Timer.start(Global.game_config.day_lenght_in_seconds)

func _on_timer_timeout() -> void:
	var task = task_scene.instantiate()
	task.initialize(daily_words, payment_per_word)
	path_to_translator.add_child(task)
	Global.client_send_task.emit(task)
