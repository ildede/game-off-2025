extends Control
class_name Clock

@onready var progress = $TextureProgressBar

func _ready() -> void:
	print("[CLOCK] _ready")
	progress.value = 0
	progress.max_value = Config.DAY_LENGHT_IN_SECONDS
	$DayCount.text = str(Global.game_state.current_day)

func _process(_delta: float) -> void:
	if Global.game_clock is Timer:
		progress.value = Global.game_clock.time_left
