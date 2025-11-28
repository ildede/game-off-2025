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
	print("[INVOICES] _on_single_invoice_clicked, day ", Global.game_state.current_day)
	get_tree().paused = true
	var total = Global.game_state.tasks_waiting_to_be_processed.reduce(func(acc, element): return acc + element.money_value, 0)
	var total_immediate = 0
	var total_upon_receipt = 0
	var total_NET7 = 0
	var total_NET30 = 0
	var total_NET60 = 0
	var total_EOM = 0
	var total_EONM = 0
	for invoice_obj in Global.game_state.tasks_waiting_to_be_processed:
		match invoice_obj.payment_terms:
			"IMMEDIATE":
				total_immediate += invoice_obj.money_value
			"UPON_RECEIPT":
				total_upon_receipt += invoice_obj.money_value
			"NET7":
				total_NET7 += invoice_obj.money_value
			"NET30":
				total_NET30 += invoice_obj.money_value
			"NET60":
				total_NET60 += invoice_obj.money_value
			"EOM":
				total_EOM += invoice_obj.money_value
			"EONM":
				total_NET7 += invoice_obj.money_value

	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "Collecting invoices"
	var message_lines: Array[String] = [
		"Today is {day} {month}".format(Global.get_current_date()),
		"You have {0} invoces waiting, for a total of {1}$ to collect".format([Global.game_state.tasks_waiting_to_be_processed.size(), total])
	]
	if total_immediate > 0: message_lines.append("{0}$ will be payed immediately".format([total_immediate]))
	if total_upon_receipt > 0: message_lines.append("{0}$ will be payed overnight".format([total_upon_receipt]))
	if total_NET7 > 0: message_lines.append("{0}$ will be payed in 7 days".format([total_NET7]))
	if total_NET30 > 0: message_lines.append("{0}$ will be payed in 30 days".format([total_NET30]))
	if total_NET60 > 0: message_lines.append("{0}$ will be payed in 60 days".format([total_NET60]))
	if total_EOM > 0: message_lines.append("{0}$ will be payed at the end of month".format([total_EOM]))
	if total_EONM > 0: message_lines.append("{0}$ will be payed at the end of next month".format([total_EONM]))

	message_lines.append("\n")
	message_lines.append("Do you want to spend some time for sending those out?")
	popup_data.lines = message_lines

	var accept_button = CustomizablePopupMessage.PopupButton.new()
	accept_button.text = "YES, I want my money"
	accept_button.action = func():
		for invoice_obj in Global.game_state.tasks_waiting_to_be_processed:
			match invoice_obj.payment_terms:
				"IMMEDIATE":
					Global.update_money.emit(invoice_obj.money_value)
				"UPON_RECEIPT":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day, invoice_obj.money_value))
				"NET7":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day+7, invoice_obj.money_value))
				"NET30":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day+30, invoice_obj.money_value))
				"NET60":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day+60, invoice_obj.money_value))
				"EOM":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day+Global.until_end_of_month(Global.game_state.current_day), invoice_obj.money_value))
				"EONM":
					Global.game_state.pending_payments.append(Models.PendingPayement.new(Global.game_state.current_day+Global.until_end_of_month(Global.game_state.current_day)+30, invoice_obj.money_value))

		Global.game_state.tasks_waiting_to_be_processed.clear()
		for child in child_added:
			child.queue_free()
		child_added.clear()
		Global.ui_update.emit()
		get_tree().paused = false

	var postpone_button = CustomizablePopupMessage.PopupButton.new()
	postpone_button.text = "No, just let me translate"
	postpone_button.action = func():
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_button, postpone_button]
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false
	$CustomPopupMessage.show_popup(popup_data)
