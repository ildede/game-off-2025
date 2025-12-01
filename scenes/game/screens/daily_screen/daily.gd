extends Node
class_name Daily

@export var texture: Texture2D
var selectable: Dictionary = {}

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS

	$Panel/StatisticGrid/Statistics.text = ""
	$Panel/StatisticGrid/Statistics.append_text("Days survived: {0}\nTranslated words: {1}\nYour budget: {2}$"
		.format([
			Global.game_state.current_day,
			Global.game_state.translated_words,
			Global.game_state.money
		]))

	var bonus1 = ClientData.get_random_bonus()
	if bonus1:
		var index_added1 = $Panel/StatisticGrid/ItemList.add_item("{name}: {cost}$\n{description}".format(bonus1), texture)
		selectable.set(index_added1, bonus1)

		var bonus2 = ClientData.get_random_bonus()
		if bonus2:
			if not bonus2.id == bonus1.id:
				var index_added2 = $Panel/StatisticGrid/ItemList.add_item("{name}: {cost}$\n{description}".format(bonus2), texture)
				selectable.set(index_added2, bonus2)

			var bonus3 = ClientData.get_random_bonus()
			if bonus3:
				if not bonus3.id == bonus1.id and not bonus3.id == bonus2.id:
					var index_added3 = $Panel/StatisticGrid/ItemList.add_item("{name}: {cost}$\n{description}".format(bonus3), texture)
					selectable.set(index_added3, bonus3)

	if selectable.is_empty():
		$Panel/StatisticGrid/ItemList.visible = false

func _on_continue_button_pressed() -> void:
	print("[DAILY] _on_continue_button_pressed")
	for bill in Global.game_state.bills:
		if bill.next_payment_day <= Global.game_state.current_day:
			Global.update_money.emit(-bill.amount)
			if bill.recurring:
				bill.next_payment_day = bill.next_payment_day + Global.until_end_of_month(bill.next_payment_day) + bill.due_day
				print("[DAILY] Bill update, now bill.next_payment_day is {0}, for a due_day of {1}".format([bill.next_payment_day, bill.due_day]))

	if not selectable.is_empty():
		var selected_list = $Panel/StatisticGrid/ItemList.get_selected_items()
		for selected_item in selected_list:
			var bonus = selectable.get(selected_item)
			print("[DAIILY] Activating {name}".format(bonus))
			Global.game_state.money -= bonus.cost

			Global.game_state.quality += bonus.quality_change
			Global.game_state.stress += bonus.stress_change
			Global.game_state.reputation += bonus.reputation_change
			Global.game_state.productivity += bonus.productivity_change
			if not bonus.default_bill_change == 0:
				for bill in Global.game_state.bills:
					bill.amount += bonus.default_bill_change

	if Global.game_state.money < 0:
		SceneTransition.fade_to_end()
	else:
		Global.update_day_count.emit(1)
		SceneTransition.fade_to_main()

func _on_item_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	print("[DAILY] _on_item_list_empty_clicked")
	$Panel/StatisticGrid/Continue.text = "CONTINUE"
	$Panel/StatisticGrid/ItemList.deselect_all()

func _on_item_list_item_selected(_index: int) -> void:
	print("[DAILY] _on_item_list_item_selected")
	$Panel/StatisticGrid/Continue.text = "BUY & CONTINUE"
