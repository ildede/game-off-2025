extends Node
class_name Daily

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/GridContainer/Label.text = ""
	$Panel/GridContainer/Label.bbcode_enabled = true
	$Panel/GridContainer/Label.append_text("[b]Daily recap: {0}[/b]".format([Global.game_state.current_day]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("[i]Bank account: {0}[/i]".format([Global.game_state.money]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("You are waiting for {0} payment from invoices you sent".format([Global.game_state.pending_payments.size()]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Tasks that are waiting for an invoice: {0}".format([Global.game_state.tasks_waiting_to_be_processed.size()]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text(
		"Until now you translated {word_count} words, during your work on {task_received} tasks (only {task_finished} completely finished)"
		.format({
			"word_count":Global.game_state.translated_words,
			"task_received": Global.game_state.task_received,
			"task_finished": Global.game_state.task_finished
		})
	)
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Your reputation: {0}".format([Global.game_state.reputation]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Your stress level: {0}/{1}".format([Global.game_state.stress, Config.MAX_STRESS_LEVEL]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("The quality perceived: {0}".format([Global.game_state.quality]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Now, your {0} clients are waiting, what do you want to do?".format([Global.game_state.clients.size()]))

func _on_continue_button_pressed() -> void:
	print("[DAILY] _on_continue_button_pressed")
	Global.update_day_count.emit(1)
	SceneTransition.fade_to_main()

func _on_pay_bills_button_pressed() -> void:
	print("[DAILY] _on_pay_bills_button_pressed")
	Global.update_money.emit(-50)
