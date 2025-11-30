extends Control
class_name ClientScene

var client_id = 0;
var path_to_translator: Path2D

func _ready() -> void:
	$Sprite.play("default")

func initialize(my_position: Vector2, translator_position: Vector2, client_data: Models.ClientObject):
	self.position = my_position
	client_id = client_data.id
	var curve = Curve2D.new()
	curve.add_point($Sprite.position)
	curve.add_point(translator_position - my_position)
	var path = Path2D.new()
	path.curve = curve
	path_to_translator = path
	add_child(path_to_translator)
	$Name.text = client_data.name

func spawn_task(task: Task) -> void:
	path_to_translator.add_child(task)


func _on_area_2d_mouse_entered() -> void:
	$Delete.visible = true

func _on_area_2d_mouse_exited() -> void:
	$Delete.visible = false

func _on_delete_pressed() -> void:
	Global.client_deleted.emit(client_id)
	$Sprite.play("delete")
	await get_tree().create_timer(2).timeout
	queue_free()
