extends Node
class_name Daily

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS

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
