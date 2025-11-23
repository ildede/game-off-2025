extends PathFollow2D
class_name Task

var money_value: float = 0
var total_time = 60
var running_time = 0

func _ready() -> void:
	$ProgressBar.value = 0

func _physics_process(delta: float) -> void:
	running_time += delta
	if running_time >= total_time: running_time = 0
	self.progress_ratio = lerp(0, 1, running_time / total_time)
	rotation = 0

func initialize(daily_words: int, payment_per_word: float):
	var actual_words = daily_words + randi_range(-50, 50)
	$ProgressBar.max_value = actual_words
	$Label.text = str(actual_words)
	money_value = actual_words * payment_per_word

func update_progress(letter: Letter) -> bool:
	$ProgressBar.value += letter.word_count
	if $ProgressBar.max_value == $ProgressBar.value:
		return true
	else:
		return false

func get_task_id() -> int:
	return get_node("CharacterBody2D").task_id
