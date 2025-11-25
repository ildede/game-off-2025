extends Node
class_name End

func _ready() -> void:
	print("[END] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/GridContainer/Label.text = ""
	$Panel/GridContainer/Label.bbcode_enabled = true
	$Panel/GridContainer/Label.append_text("[b]BURNOUT! On day: {0}[/b]".format([Global.game_state.current_day]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("[i]Bank account: {0}[/i]".format([Global.game_state.money]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Task waiting invoice: {0}".format([Global.game_state.tasks_waiting_to_be_processed.size()]))
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
	$Panel/GridContainer/Label.append_text("Your reputation: {0}".format([Global.game_state.reputation]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Your stress level: {0}/{1}".format([Global.game_state.stress, Global.game_config.max_stress_level]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("The quality perceived: {0}".format([Global.game_state.quality]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("Now, your {0} clients will find someone else, and you?".format([Global.game_state.clients.size()]))
	$Panel/GridContainer/Label.newline()
	$Panel/GridContainer/Label.append_text("what do you want to do?")

func _on_start_button_pressed() -> void:
	print("[END] _on_start_button_pressed")
	Global.start_new_game()
	SceneTransition.fade_to_main()
