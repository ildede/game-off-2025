extends Node
class_name Daily

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	var message = "You finished day {day_count} with {money}$ in your bank."
	$Panel/GridContainer/Label.text = message.format({"day_count": Global.game_state.current_day,"money": Global.game_state.money	})

func _on_continue_button_pressed() -> void:
	print("[DAILY] _on_continue_button_pressed")
	Global.update_day_count.emit(1)
	SceneTransition.fade_to_main()

func _on_pay_bills_button_pressed() -> void:
	print("[DAILY] _on_pay_bills_button_pressed")
	Global.update_money.emit(-50)
