extends PathFollow2D
class_name Task

var money_value: float = 0
var total_time = Config.DAY_LENGHT_IN_SECONDS
var running_time = 0
var remaining_words = 1

func _ready() -> void:
	$ProgressBar.value = 0

func _physics_process(delta: float) -> void:
	running_time += delta
	if running_time >= total_time: running_time = 0
	self.progress_ratio = lerp(0, 1, running_time / total_time)
	rotation = 0

func initialize(daily_words: int, payment_per_word: float, deadline_in_days: int):
	var variation = roundi(daily_words * 0.05)
	var actual_words = daily_words + randi_range(-variation, +variation)
	remaining_words = actual_words
	$ProgressBar.max_value = actual_words
	$Label.text = str(actual_words)
	money_value = actual_words * payment_per_word
	total_time = Config.DAY_LENGHT_IN_SECONDS * (deadline_in_days + 1)

func update_progress(letter: Letter) -> bool:
	$ProgressBar.value += letter.word_count
	remaining_words -= letter.word_count
	$Label.text = str(remaining_words)
	if $ProgressBar.max_value == $ProgressBar.value:
		return true
	else:
		return false

func get_task_id() -> int:
	return get_node("CharacterBody2D").task_id
