extends Node
class_name Daily

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Global.game_state.ongoing_task.size() > 0:
		$Panel/GridContainer/OvertimeGrid.visible = true
		$Panel/GridContainer/OvertimeGrid/Description.text = ""
		# Cambiare verso 'You have {0} ongoing tasks due tomorrow' ed elenco dei task. Si possono fare max 2k parole su un solo task, stesso gioco di stress.
		$Panel/GridContainer/OvertimeGrid/Description.append_text("You have {0} ongoing tasks due tomorrow. Do you want to work overtime?\nYou'll clear one pending task with under 2000 words, but your stress will increase by 1 point for every 400 words."
			.format([Global.game_state.ongoing_task.size()]))

	$Panel/GridContainer/StatisticGrid/Statistics.text = ""
	$Panel/GridContainer/StatisticGrid/Statistics.append_text("Days survived: {0}\nTranslated words: {1}\nYour budget: {2}$"
		.format([
			Global.game_state.current_day,
			Global.game_state.translated_words,
			Global.game_state.money
		]))


func _on_continue_button_pressed() -> void:
	print("[DAILY] _on_continue_button_pressed")
	for bill in Global.game_state.bills:
		if bill.next_payment_day <= Global.game_state.current_day:
			Global.update_money.emit(-bill.amount)
			if bill.recurring:
				bill.next_payment_day = bill.next_payment_day + Global.until_end_of_month(bill.next_payment_day) + bill.due_day
				print("bill update, now bill.next_payment_day is {0}, for a due_day of {1}".format([bill.next_payment_day, bill.due_day]))

	if Global.game_state.money < 0:
		SceneTransition.fade_to_end()
	else:
		Global.update_day_count.emit(1)
		SceneTransition.fade_to_main()

func _on_overtime_button_pressed() -> void:
	print("[DAILY] _on_overtime_button_pressed")
	var get_rid = Global.game_state.ongoing_task.filter(func(t:Models.OngoingTask):return t.remaining_words < 2000).pick_random()
	if get_rid != null:
		var found_index = Global.game_state.ongoing_task.find_custom(func(t): return t.task_id == get_rid.task_id)
		if found_index >= 0:
			var finished_task = Global.game_state.ongoing_task.pop_at(found_index)
			var client_index = Global.game_state.clients.find_custom(func(c): return c.id == finished_task.client_id)
			var client_info: Models.ClientObject = Global.game_state.clients[client_index]
			var invoice_info = Models.InvoiceObject.new(finished_task, client_info)
			Global.game_state.translated_words += finished_task.total_words
			Global.game_state.reputation += finished_task.reputation_on_success
			Global.game_state.tasks_waiting_to_be_processed.append(invoice_info)
			Global.game_state.stress += finished_task.remaining_words as float/400.0

	Global.update_day_count.emit(1)
	SceneTransition.fade_to_main()
