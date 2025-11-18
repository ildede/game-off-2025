extends Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wait_time = randi_range(1, 10)
