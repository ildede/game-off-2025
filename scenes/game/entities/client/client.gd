extends Control
class_name ClientScene

var client_id = 0;
var path_to_translator: Path2D
var _client_data: Models.ClientObject = Models.ClientObject.new()

func _ready() -> void:
	$Sprite.play("default")

func initialize(translator_position: Vector2, client_data: Models.ClientObject):
	_client_data = client_data
	self.position = client_data.position
	client_id = client_data.id
	var curve = Curve2D.new()
	curve.add_point($Sprite.position)
	curve.add_point(translator_position - client_data.position)
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
	$Info.visible = true

func _on_area_2d_mouse_exited() -> void:
	$Delete.visible = false
	$Info.visible = false

func _on_delete_pressed() -> void:
	Global.client_deleted.emit(client_id)
	$Sprite.play("delete")
	await get_tree().create_timer(2).timeout
	queue_free()


func _on_info_pressed() -> void:
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = _client_data.name
	var pay_terms = ""
	match _client_data.payment_terms:
		"IMMEDIATE":
			pay_terms = "immediate after receiving the invoice"
		"UPON_RECEIPT":
			pay_terms = "we will pay overnight after receiving the invoice"
		"NET7":
			pay_terms = "7 days after invoice"
		"NET30":
			pay_terms = "30 days after invoice"
		"NET60":
			pay_terms = "60 days after invoice"
		"EOM":
			pay_terms = "At the end of the month"
		"EONM":
			pay_terms = "At the end of next month"
	var message_lines: Array[String] = [
		"Rates: {0}$ per word".format([_client_data.payment_per_word]),
		"Payment terms: {0}".format([pay_terms])
	]
	popup_data.lines = message_lines

	var btns: Array[CustomizablePopupMessage.PopupButton] = []
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false

	$CustomPopupMessage.show_popup(popup_data)
