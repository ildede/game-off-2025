extends PathFollow2D

var speed = 150

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta):
	set_progress(get_progress() + speed * delta)
	rotation = 0

#func _on_character_body_2d_area_entered(area: Area2D) -> void:
	#print("task _on_character_body_2d_area_entered with: ", area)
#
#func _on_character_body_2d_body_entered(body: Node2D) -> void:
	#print("task _on_character_body_2d_body_entered with: ", body)
