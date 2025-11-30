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
	if client_data.loyalty <= (Config.MAX_CLIENT_LOYALTY/3)*2:
		$Skull1.visible = true
		$Skull1.play("default")
	if client_data.loyalty <= Config.MAX_CLIENT_LOYALTY/3:
		$Skull2.visible = true
		$Skull2.play("default")
	if client_data.loyalty <= Config.MIN_CLIENT_LOYALTY:
		$Skull3.visible = true
		Global.client_deleted.emit(client_id)
		$Sprite.play("delete")
		await get_tree().create_timer(2).timeout
		queue_free()

func loyalty_updated(loyalty: float):
	if loyalty <= (Config.MAX_CLIENT_LOYALTY/3)*2:
		$Skull1.visible = true
		$Skull1.play("default")
	else:
		$Skull1.visible = false
	if loyalty <= Config.MAX_CLIENT_LOYALTY/3:
		$Skull2.visible = true
		$Skull2.play("default")
	else:
		$Skull2.visible = false
	if loyalty <= Config.MIN_CLIENT_LOYALTY:
		$Skull3.visible = true
		Global.client_deleted.emit(client_id)
		$Sprite.play("delete")
		var tree = get_tree()
		if not tree == null:
			await tree.create_timer(2).timeout
		queue_free()
	else:
		$Skull3.visible = false

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
