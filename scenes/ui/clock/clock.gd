extends Control
class_name Clock

@onready var progress = $TextureProgressBar
@onready var day = $GridContainer/DayCount
@onready var month = $GridContainer/Month

func _ready() -> void:
	print("[CLOCK] _ready")
	progress.value = 0
	progress.max_value = Config.DAY_LENGHT_IN_SECONDS
	var today = Global.get_current_date()
	day.text = today.day
	month.text = today.month

func _process(_delta: float) -> void:
	if Global.game_clock is Timer:
		progress.value = Global.game_clock.time_left
