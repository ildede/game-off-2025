extends Area2D

var speed = 200
var possible_letters = ["A","B","C","D"]
var target: PathFollow2D

signal task_colpito

func _ready() -> void:
	var imported_resource = load("res://letters/{0}.png".format([possible_letters.pick_random()]))
	$Sprite2D.texture = imported_resource

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.move_toward(target.global_position, speed * delta)
	else:
		queue_free()

#func _on_area_entered(area: Area2D) -> void:
	#print("letter _on_area_entered with: ", area)
	#hide()
	#task_colpito.emit(area)

func _on_body_entered(body: Node2D) -> void:
	print("letter _on_body_entered with: ", body)
	queue_free()
	task_colpito.emit(body)
