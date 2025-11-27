extends Node2D
class_name Main

@onready var game_information: GameInformation = $GameInformation
@onready var screen = get_viewport().get_visible_rect().size
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")
@onready var task_scene = preload("res://scenes/game/entities/task/task.tscn")

@onready var active_clients: Dictionary = {}
@onready var active_tasks: Dictionary = {}

func _ready() -> void:
	print("[MAIN] _ready")
	Global.set_clock($GameClock)
	Global.game_over.connect(handle_game_over)
	Global.task_finished.connect(handle_task_finished)

	for client_info in Global.game_state.clients:
		var added = add_new_client_to_scene(client_info)
		active_clients.set(client_info.id, added)

	for task_info: Models.OngoingTask in Global.game_state.ongoing_task:
		if active_clients.has(task_info.client_id):
			var task: Task = task_scene.instantiate()
			task.initialize(task_info)
			active_clients.get(task_info.client_id).spawn_task(task)
			active_tasks.set(task.get_task_id(), task)
			Global.client_send_task.emit(task)

	if Global.game_state.current_day == 1:
		$EventSpawner.start(0.2)
	else:
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
	$EventSpawner.timeout.connect(handle_spawn_random_event)

	$GameClock.start(Config.DAY_LENGHT_IN_SECONDS)
	$GameClock.timeout.connect(handle_end_of_the_day)

	$TaskSpawner.start(Config.SECONDS_BETWEEN_TASKS)
	$TaskSpawner.timeout.connect(handle_spawn_tasks)

	get_tree().paused = false

func handle_spawn_random_event() -> void:
	print("[MAIN] handle_spawn_random_event")
	var client_info = ClientData.get_random_client()
	if not active_clients.has(client_info.id):
		get_tree().paused = true
		open_popup_message_for_new_client(client_info)

func handle_spawn_tasks() -> void:
	print("[MAIN] handle_spawn_tasks")
	for client in Global.game_state.clients:
		if active_clients.has(client.id):
			var task_object = client.get_task_to_spawn(Global.game_state.current_day)
			if task_object:
				var task: Task = task_scene.instantiate()
				var ongoing_task = Models.OngoingTask.new(client.id, task_object)
				task.initialize(ongoing_task)
				Global.game_state.ongoing_task.append(ongoing_task)
				active_clients.get(client.id).spawn_task(task)
				active_tasks.set(task.get_task_id(), task)
				Global.client_send_task.emit(task)

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

func handle_end_of_the_day() -> void:
	print("[MAIN] handle_end_of_the_day")
	for ongoing_task in Global.game_state.ongoing_task:
		var task: Task = active_tasks.get(ongoing_task.task_id)
		ongoing_task.remaining_words = task.remaining_words
	get_tree().paused = true
	SceneTransition.fade_to_new_day()

func handle_game_over() -> void:
	print("[MAIN] handle_game_over")
	SceneTransition.fade_to_end()


func add_new_client_to_scene(client_info: Models.ClientObject) -> ClientScene:
	print("[MAIN] add_new_client_to_scene")
	var client: ClientScene = client_scene.instantiate()

	var client_position = Vector2(randi_range(700, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position, client_info)
	add_child(client)
	return client

func open_popup_message_for_new_client(client: Models.ClientObject) -> void:
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "New email"
	var message_lines: Array[String] = [client.engagement_email]
	popup_data.lines = message_lines

	var accept_btn = CustomizablePopupMessage.PopupButton.new()
	accept_btn.text = "Accept"
	accept_btn.action = func():
		Global.new_client_accepted.emit(client)
		var added = add_new_client_to_scene(client)
		active_clients.set(client.id, added)
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
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
