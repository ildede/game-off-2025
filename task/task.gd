extends PathFollow2D
class_name Task

var speed = 150

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta):
	set_progress(get_progress() + speed * delta)
	rotation = 0
