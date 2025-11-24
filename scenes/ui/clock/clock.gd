extends Control
class_name Clock

@onready var timer = $Timer
@onready var progress = $TextureProgressBar

signal end_of_the_day

func _ready() -> void:
	print("[CLOCK] _ready")
	timer.start(Global.game_config.day_lenght_in_seconds)
	progress.value = 0
	progress.max_value = timer.wait_time
	$DayCount.text = str(Global.game_state.current_day)

func _process(_delta: float) -> void:
	progress.value = timer.time_left

func _on_timer_timeout() -> void:
	end_of_the_day.emit()
	$DayCount.text = str(Global.game_state.current_day)
