extends Control
class_name Clock

@onready var timer = $Timer
@onready var progress = $TextureProgressBar

signal end_of_the_day

var day_count: int = 1

func _ready() -> void:
	progress.value = 0
	progress.max_value = timer.wait_time
	$DayCount.text = str(day_count)

func _process(_delta: float) -> void:
	progress.value = timer.time_left

func _on_timer_timeout() -> void:
	end_of_the_day.emit()

func update_day_count(days: int) -> void:
	day_count += days
	$DayCount.text = str(day_count)
