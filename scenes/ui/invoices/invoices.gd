extends Node2D
class_name Invoices

var invoice = preload("res://scenes/ui/invoices/invoice.tscn")
var child_added = []

func _ready() -> void:
	print("[INVOICES] _ready")
	Global.task_finished.connect(add_invoice)
	redraw_invoices()

func add_invoice(id: int, value: float):
	print("[INVOICES] add_invoice")
	var created = Global.InvoiceObject.new(id, value)
	var new_invoice = invoice.instantiate()
	new_invoice.position = self.global_position + Vector2(randi_range(-50,50), -(Global.game_state.tasks_waiting_to_be_processed.size()*100))
	Global.game_state.tasks_waiting_to_be_processed.append(created)
	child_added.append(new_invoice)
	add_child(new_invoice)
	new_invoice.invoice_clicked.connect(_on_single_invoice_clicked)

func redraw_invoices() -> void:
	var count = 0
	for inv in Global.game_state.tasks_waiting_to_be_processed:
		var new_invoice = invoice.instantiate()
		new_invoice.position = self.global_position + Vector2(randi_range(-50,50), -(count*100))
		child_added.append(new_invoice)
		add_child(new_invoice)
		new_invoice.invoice_clicked.connect(_on_single_invoice_clicked)
		count += 1

func _on_single_invoice_clicked():
	print("[INVOICES] _on_single_invoice_clicked, collecting everything")
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



	
