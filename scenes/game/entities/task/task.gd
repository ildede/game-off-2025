extends PathFollow2D
class_name Task

var speed = 50
var money_value: float = 0

func _ready() -> void:
	$ProgressBar.value = 0

func _physics_process(delta: float) -> void:
	move(delta)

func initialize(daily_words: int, payment_per_word: float):
	var actual_words = daily_words + randi_range(-50, 50)
	$ProgressBar.max_value = actual_words
	$Label.text = str(actual_words)
	money_value = actual_words * payment_per_word

func move(delta):
	set_progress(get_progress() + speed * delta)
	rotation = 0

func update_progress() -> bool:
	$ProgressBar.value += 1
	if $ProgressBar.max_value == $ProgressBar.value:
		return true
	else:
		return false
