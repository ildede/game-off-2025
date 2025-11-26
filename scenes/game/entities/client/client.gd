extends Node2D
class_name ClientScene

const task_scene = preload("res://scenes/game/entities/task/task.tscn")

var client_id = 0;
var path_to_translator: Path2D
var translator: Node2D
var daily_words: int = 0
var payment_per_word: float = 0
var deadline_in_days: int = 0

func _ready() -> void:
	$Timer.start(Config.DAY_LENGHT_IN_SECONDS)

func initialize(my_position: Vector2, translator_position: Vector2, client_data: Models.ClientObject):
	self.position = my_position
	client_id = client_data.id
	var curve = Curve2D.new()
	curve.add_point($Sprite.position)
	curve.add_point(translator_position - my_position)
	var path = Path2D.new()
	path.curve = curve
	path_to_translator = path
	add_child(path_to_translator)
	$Name.text = client_data.name
	daily_words = client_data.recurring_tasks[0].words
	payment_per_word = client_data.payment_per_word
	deadline_in_days = client_data.recurring_tasks[0].deadline_days
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	var task: Task = task_scene.instantiate()
	task.initialize(daily_words, payment_per_word, deadline_in_days)
	path_to_translator.add_child(task)
	Global.client_send_task.emit(task)
