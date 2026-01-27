extends Node
class_name Overtime

@export var texture: Texture2D

var selectable: Dictionary = {}
var selected = -1

func _ready() -> void:
	print("[DAILY] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/OvertimeGrid/Description.text = ""
	$Panel/OvertimeGrid/Description.append_text("You have {0} ongoing tasks due soon. Do you want to work overtime on one of theme?\nYou'll clear a maximum of 2000 words on that task, but your stress will increase by 1 point for every 400 words."
		.format([Global.game_state.ongoing_task.filter(func(t:Models.OngoingTask):return t.deadline_days <= 3).size()]))

	for task: Models.OngoingTask in Global.game_state.ongoing_task.filter(func(t:Models.OngoingTask):return t.deadline_days <= 3):
		var index_added = $Panel/OvertimeGrid/ItemList.add_item(
			"Words left\n{0}".format([task.remaining_words]),
			texture
		)
		selectable.set(index_added, task.task_id)

func _on_overtime_button_pressed() -> void:
	print("[DAILY] _on_overtime_button_pressed")
	if not selected == -1:
		var found_index = Global.game_state.ongoing_task.find_custom(func(t): return t.task_id == selectable.get(selected))
		if found_index >= 0:
			var to_work_on = Global.game_state.ongoing_task[found_index]
			if to_work_on.remaining_words < 2000:
				var finished_task = Global.game_state.ongoing_task.pop_at(found_index)
				var client_index = Global.game_state.clients.find_custom(func(c): return c.id == finished_task.client_id)
				var client_info: Models.ClientObject = Global.game_state.clients[client_index]
				var invoice_info = Models.InvoiceObject.new(finished_task, client_info)
				Global.game_state.translated_words += finished_task.total_words
				Global.game_state.reputation += finished_task.reputation_on_success
				Global.game_state.tasks_waiting_to_be_processed.append(invoice_info)
				Global.game_state.stress += finished_task.remaining_words as float/400.0
			else:
				to_work_on.remaining_words -= 2000
				Global.game_state.translated_words += 2000
				Global.game_state.stress += 5

	SceneTransition.fade_to_new_day()

func _on_item_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	$Panel/OvertimeGrid/Overtime.text = "NO WAY!"
	$Panel/OvertimeGrid/ItemList.deselect_all()
	selected = -1

func _on_item_list_item_selected(index: int) -> void:
	$Panel/OvertimeGrid/Overtime.text = "DO OVERTIME!"
	selected = index
