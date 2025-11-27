extends Node2D
class_name Invoices

var invoice_scene = preload("res://scenes/ui/invoices/invoice.tscn")
var child_added = []

func _ready() -> void:
	print("[INVOICES] _ready")
	redraw_invoices()

func add_invoice(invoice_info: Models.InvoiceObject):
	print("[INVOICES] add_invoice")
	var invoice_instance = invoice_scene.instantiate()
	invoice_instance.position = self.global_position + Vector2(randi_range(-50,50), -(Global.game_state.tasks_waiting_to_be_processed.size()*100))
	Global.game_state.tasks_waiting_to_be_processed.append(invoice_info)
	child_added.append(invoice_instance)
	call_deferred("add_child", invoice_instance)
	invoice_instance.invoice_clicked.connect(_on_single_invoice_clicked)

func redraw_invoices() -> void:
	var count = 0
	for inv in Global.game_state.tasks_waiting_to_be_processed:
		var invoice_instance = invoice_scene.instantiate()
		invoice_instance.position = self.global_position + Vector2(randi_range(-50,50), -(count*100))
		child_added.append(invoice_instance)
		add_child(invoice_instance)
		invoice_instance.invoice_clicked.connect(_on_single_invoice_clicked)
		count += 1

func _on_single_invoice_clicked():
	print("[INVOICES] _on_single_invoice_clicked")
	get_tree().paused = true
	var total = Global.game_state.tasks_waiting_to_be_processed.reduce(func(acc, element): return acc + element.money_value, 0)

	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "Collecting invoices"
	var message_lines: Array[String] = [
		"You have {0} invoce waiting".format([Global.game_state.tasks_waiting_to_be_processed.size()]),
		"For a total of {0}$ to collect".format([total])
	]
	popup_data.lines = message_lines
	var button = CustomizablePopupMessage.PopupButton.new()
	button.text = "Send & Collect"
	button.action = func():
		Global.update_money.emit(total)
		Global.game_state.tasks_waiting_to_be_processed.clear()
		for child in child_added:
			child.queue_free()
		child_added.clear()
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [button]
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false
	$CustomPopupMessage.show_popup(popup_data)
