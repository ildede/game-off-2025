extends Control

@onready var timer = $Timer
@onready var progress = $TextureProgressBar

func _ready() -> void:
	progress.value = 0
	progress.max_value = timer.wait_time

func _process(_delta: float) -> void:
	progress.value = timer.time_left
