extends Node2D
class_name Main

@onready var game_information: GameInformation = $GameInformation
@onready var screen = get_viewport().get_visible_rect().size
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")
@onready var task_scene = preload("res://scenes/game/entities/task/task.tscn")

@onready var active_clients: Dictionary = {}
@onready var active_tasks: Dictionary = {}

var clients_sent_something_today: Array[int]
var active_clients_count: int

var custom_functions: Dictionary[String, Callable] = {
	"one": func():
		print("one is called"),
	"two": func():
		print("two is called"),
	"lose_random_client": func ():
		Global.client_deleted.emit(active_clients.keys().pick_random()),
	"ten_k_words_today": func ():
		var tmp = Global.game_state.productivity
		Global.update_productivity.emit(10000-tmp)
		$GameClock.timeout.connect(func (): Global.update_productivity.emit(-(10000-tmp))),
	"double_words_today": func ():
		var tmp = Global.game_state.productivity
		Global.update_productivity.emit(tmp)
		$GameClock.timeout.connect(func (): Global.update_productivity.emit(-tmp)),
	"qworse_acquires": func ():
		var choosen = active_clients.values().filter(func(c):
			print(c._client_data.name)
			return not "worse" in c._client_data.name
		).pick_random()
		print(choosen)
		if is_instance_valid(choosen):
			print(choosen._client_data.name)
			Global.qworse_acquires.emit(choosen.client_id),
	"lose_half_of_day": func ():
		Global.game_clock.start(Global.game_clock.time_left/2),
}

func _ready() -> void:
	print("[MAIN] _ready")
	clients_sent_something_today = []
	active_clients_count = 0
	Global.set_clock($GameClock)
	Global.game_over.connect(handle_game_over)
	Global.task_finished.connect(handle_task_finished)
	Global.task_failed.connect(handle_task_failed)
	Global.task_deleted.connect(handle_task_deleted)
	Global.client_deleted.connect(handle_client_deleted)

	for client_info in Global.game_state.clients:
		if not client_info.is_removed:
			var added = add_new_client_to_scene(client_info)
			active_clients.set(client_info.id, added)

	for task_info: Models.OngoingTask in Global.game_state.ongoing_task:
		if active_clients.has(task_info.client_id):
			var task: Task = task_scene.instantiate()
			task.initialize(task_info)
			active_clients.get(task_info.client_id).spawn_task(task)
			active_tasks.set(task.get_task_id(), task)
			Global.client_send_task.emit(task)

	var remaining_payments: Array[Models.PendingPayement] = []
	for payment in Global.game_state.pending_payments:
		if payment.due_date <= Global.game_state.current_day:
			Global.update_money.emit(payment.money_value)
		else:
			remaining_payments.append(payment)
	Global.game_state.pending_payments = remaining_payments

	if Global.game_state.current_day == 1:
		$EventSpawner.start(0.2)
	else:
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
	$EventSpawner.timeout.connect(handle_spawn_random_event)

	$GameClock.start(Config.DAY_LENGHT_IN_SECONDS)
	$GameClock.timeout.connect(handle_end_of_the_day)

	$TaskSpawner.start(Config.SECONDS_BETWEEN_TASKS)
	$TaskSpawner.timeout.connect(handle_spawn_tasks)

	Global.ui_update.emit()
	get_tree().paused = false

func handle_spawn_random_event() -> void:
	print("[MAIN] handle_spawn_random_event")
	if active_clients_count <= 0:
		var client_info = ClientData.get_random_client()
		open_popup_message_for_new_client(client_info)
	else:
		if randf() < 0.6:
			var event_info = ClientData.get_random_event()
			if event_info:
				open_popup_message_for_new_event(event_info)
		else:
			var client_info = ClientData.get_random_client()
			if not active_clients.has(client_info.id):
				open_popup_message_for_new_client(client_info)

func handle_spawn_tasks() -> void:
	print("[MAIN] handle_spawn_tasks")
	for client in Global.game_state.clients:
		if active_clients.has(client.id) and not client.is_removed and not clients_sent_something_today.has(client.id):
			var task_object = client.get_task_to_spawn(Global.game_state.current_day)
			if task_object:
				if task_object.need_confirmation_email:
					open_popup_message_for_new_task(client, task_object)
				else:
					add_new_task_to_scene(client.id, task_object)

func handle_task_finished(task_id: int) -> void:
	print("[MAIN] handle_task_finished for task_id ", task_id)
	active_tasks.erase(task_id)

	var found_index = Global.game_state.ongoing_task.find_custom(func(t): return t.task_id == task_id)
	if found_index >= 0:
		var finished_task = Global.game_state.ongoing_task.pop_at(found_index)
		Global.update_reputation.emit(finished_task.reputation_on_success)
		var client_index = Global.game_state.clients.find_custom(func(c): return c.id == finished_task.client_id)
		var client_info: Models.ClientObject = Global.game_state.clients[client_index]
		var invoice_info = Models.InvoiceObject.new(finished_task, client_info)
		$Invoices.add_invoice(invoice_info)

func handle_task_failed(task_id: int) -> void:
	print("[MAIN] handle_task_failed for task_id ", task_id)
	active_tasks.erase(task_id)

	var found_index = Global.game_state.ongoing_task.find_custom(func(t): return t.task_id == task_id)
	if found_index >= 0:
		var finished_task = Global.game_state.ongoing_task.pop_at(found_index)
		Global.update_reputation.emit(finished_task.reputation_on_failure)
		Global.update_stress.emit(Config.STRESS_ON_TASK_FAILED)
		var client_index = Global.game_state.clients.find_custom(func(c): return c.id == finished_task.client_id)
		Global.game_state.clients[client_index].loyalty -= Config.MAX_CLIENT_LOYALTY/3
		var client_instance = active_clients.get(finished_task.client_id)
		client_instance.loyalty_updated(Global.game_state.clients[client_index].loyalty)

func handle_task_deleted(task_id: int) -> void:
	print("[MAIN] handle_task_deleted for task_id ", task_id)
	active_tasks.erase(task_id)

	var found_index = Global.game_state.ongoing_task.find_custom(func(t): return t.task_id == task_id)
	if found_index >= 0:
		var finished_task = Global.game_state.ongoing_task.pop_at(found_index)
		Global.update_reputation.emit(finished_task.reputation_on_failure/2)

func handle_client_deleted(client_id: int) -> void:
	print("[MAIN] handle_client_deleted for client_id ", client_id)
	active_clients.set(client_id, {})
	active_clients_count -= 1

	var client_index = Global.game_state.clients.find_custom(func(c): return c.id == client_id)
	if client_index >= 0:
		Global.game_state.clients[client_index].is_removed = true
		Global.update_reputation.emit(-5)

	var ids_to_delete = Global.game_state.ongoing_task.filter(func(t): return t.client_id == client_id).map(func(t): return t.task_id)
	for id in ids_to_delete:
		Global.task_deleted.emit(id)

func handle_end_of_the_day() -> void:
	print("[MAIN] handle_end_of_the_day")
	for ongoing_task in Global.game_state.ongoing_task:
		var task: Task = active_tasks.get(ongoing_task.task_id)
		ongoing_task.remaining_words = task.remaining_words
	get_tree().paused = true
	if Global.game_state.ongoing_task.filter(func(t:Models.OngoingTask):return t.deadline_days <= 2).size() > 0:
		SceneTransition.fade_to_overtime()
	else:
		SceneTransition.fade_to_new_day()

func handle_game_over() -> void:
	print("[MAIN] handle_game_over")
	get_tree().paused = true
	SceneTransition.fade_to_end()


func add_new_client_to_scene(client_info: Models.ClientObject) -> ClientScene:
	print("[MAIN] add_new_client_to_scene")
	var client: ClientScene = client_scene.instantiate()
	if client_info.position == Vector2.ZERO:
		client_info.position = Vector2(
			randi_range($WorldPanel.position[0]+140, $WorldPanel.position[0]+$WorldPanel.size[0]-140),
			randi_range($WorldPanel.position[1]+110, $WorldPanel.position[1]+$WorldPanel.size[1]-110)
		)
	var translator_position = $Translator.global_position
	client.initialize(translator_position, client_info)
	add_child(client)
	active_clients_count += 1
	return client

func open_popup_message_for_new_client(client: Models.ClientObject) -> void:
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "New email from {0}".format([client.name])
	var message_lines: Array[String] = [client.engagement_email()]
	popup_data.lines = message_lines

	var accept_btn = CustomizablePopupMessage.PopupButton.new()
	accept_btn.text = "Accept"
	accept_btn.action = func():
		Global.new_client_accepted.emit(client)
		var added = add_new_client_to_scene(client)
		active_clients.set(client.id, added)
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		ClientData.client_accepted(client.id)
		get_tree().paused = false

	var refuse_btn = CustomizablePopupMessage.PopupButton.new()
	refuse_btn.text = "Refuse"
	refuse_btn.action = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_btn, refuse_btn]
	popup_data.buttons = btns

	popup_data.on_close = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		get_tree().paused = false

	$CustomPopupMessage.show_popup(popup_data)

func open_popup_message_for_new_event(event: Models.EventObject) -> void:
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = event.name
	var message_lines: Array[String] = [event.description]
	popup_data.lines = message_lines

	var accept_btn = CustomizablePopupMessage.PopupButton.new()
	accept_btn.text = event.accept_btn if event.accept_btn != "" else "I hereby accept"
	accept_btn.action = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		if not event.default_bill_change == 0:
			for bill in Global.game_state.bills:
				bill.amount += event.default_bill_change
		Global.update_quality.emit(event.quality_change)
		Global.update_stress.emit(event.stress_change)
		Global.update_reputation.emit(event.reputation_change)
		Global.update_productivity.emit(event.productivity_change)
		for func_name in event.custom_functions:
			custom_functions[func_name].call()
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_btn]
	popup_data.buttons = btns

	popup_data.on_close = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		if not event.default_bill_change == 0:
			for bill in Global.game_state.bills:
				bill.amount += event.default_bill_change
		Global.update_quality.emit(event.quality_change)
		Global.update_stress.emit(event.stress_change)
		Global.update_reputation.emit(event.reputation_change)
		Global.update_productivity.emit(event.productivity_change)
		get_tree().paused = false

	$CustomPopupMessage.add_theme_icon_override("close", ImageTexture.new())
	$CustomPopupMessage.show_popup(popup_data)


func add_new_task_to_scene(client_id: int, task_info: Models.TaskObject) -> void:
	var task_instance: Task = task_scene.instantiate()
	var ongoing_task = Models.OngoingTask.new(client_id, task_info)
	task_instance.initialize(ongoing_task)
	Global.game_state.ongoing_task.append(ongoing_task)
	active_clients.get(client_id).spawn_task(task_instance)
	active_tasks.set(task_instance.get_task_id(), task_instance)
	Global.client_send_task.emit(task_instance)
	Global.handle_client_send_task(task_instance)
	clients_sent_something_today.append(client_id)

func open_popup_message_for_new_task(client: Models.ClientObject, task: Models.TaskObject) -> void:
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "New email from {0}".format([client.name])
	var message_lines: Array[String] = [
		"We have a new task for you",
		"Total words: {0}".format([task.words]),
		"Deadline in days: {0}".format([task.deadline_days])
	]
	popup_data.lines = message_lines

	var accept_btn = CustomizablePopupMessage.PopupButton.new()
	accept_btn.text = "Accept"
	accept_btn.action = func():
		add_new_task_to_scene(client.id, task)
		get_tree().paused = false

	var refuse_btn = CustomizablePopupMessage.PopupButton.new()
	refuse_btn.text = "Refuse"
	refuse_btn.action = func():
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_btn, refuse_btn]
	popup_data.buttons = btns

	popup_data.on_close = func():
		get_tree().paused = false

	$CustomPopupMessage.show_popup(popup_data)
