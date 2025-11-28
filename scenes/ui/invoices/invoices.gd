extends Node2D
class_name Invoices

var invoice_scene = preload("res://scenes/ui/invoices/invoice.tscn")
var child_added = []

func _ready() -> void:
	#var task_obj = Models.TaskObject.new()
	#task_obj.words = 100
#
	#var ong1 = Models.OngoingTask.new(1, task_obj)
	#ong1.client_id = 10
	#var client1 = Models.ClientObject.new()
	#client1.id = 10
	#client1.payment_per_word = 0.04
	#client1.payment_terms = "IMMEDIATE"
	#var invoice_info1 = Models.InvoiceObject.new(ong1, client1)
	#Global.game_state.tasks_waiting_to_be_processed.append(invoice_info1)
#
	#var ong2 = Models.OngoingTask.new(2, task_obj)
	#ong2.client_id = 20
	#var client2 = Models.ClientObject.new()
	#client2.id = 20
	#client2.payment_per_word = 0.04
	#client2.payment_terms = "NET7"
	#var invoice_info2 = Models.InvoiceObject.new(ong2, client2)
	#Global.game_state.tasks_waiting_to_be_processed.append(invoice_info2)

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
	var total_NET7 = 0
	var total_NET30 = 0
	var total_NET60 = 0
	var total_EOM = 0
	var total_EONM = 0
	for invoice_obj in Global.game_state.tasks_waiting_to_be_processed:
		match invoice_obj.payment_terms:
			"IMMEDIATE":
				total_immediate += invoice_obj.money_value
			"NET7":
				total_NET7 += invoice_obj.money_value
			"NET30":
				total_immediate += invoice_obj.money_value
			"NET60":
				total_NET7 += invoice_obj.money_value
			"EOM":
				total_immediate += invoice_obj.money_value
			"EONM":
				total_NET7 += invoice_obj.money_value

	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "Collecting invoices"
	var message_lines: Array[String] = [
		"Today is {0}".format([Global.day_number_to_date(Global.game_state.current_day)]),
		"You have {0} invoces waiting, for a total of {1}$ to collect".format([Global.game_state.tasks_waiting_to_be_processed.size(), total])
	]
	if total_immediate > 0: message_lines.append("{0}$ will be payed immediately".format([total_immediate]))
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
		get_tree().paused = false

	var postpone_button = CustomizablePopupMessage.PopupButton.new()
	postpone_button.text = "No, just let me translate"
	postpone_button.action = func():
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_button, postpone_button]
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false
	$CustomPopupMessage.show_popup(popup_data)
