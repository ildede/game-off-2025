extends Node

signal new_client_accepted(client_info: Models.ClientObject)
signal client_send_task(task: Task)
signal letter_hit_task(letter: Letter, task: Task)
signal task_finished(id: int, value: float)
signal update_reputation(value: float)
signal update_stress(value: float)
signal update_quality(value: float)
signal update_money(value: float)
signal update_day_count(value: int)

signal game_over
signal ui_update

@onready var game_state: Models.State = Models.State.new()
var game_clock: Timer

func _ready() -> void:
	print("[GLOBAL] _ready")
	new_client_accepted.connect(handle_new_client_accepted)
	client_send_task.connect(handle_client_send_task)
	letter_hit_task.connect(handle_letter_hit_task)
	task_finished.connect(handle_task_finished)
	update_reputation.connect(handle_update_reputation)
	update_stress.connect(handle_update_stress)
	update_quality.connect(handle_update_quality)
	update_money.connect(handle_update_money)
	update_day_count.connect(handle_update_day_count)
	game_over.connect(handle_game_over)

func set_clock(timer: Timer):
	game_clock = timer

func handle_new_client_accepted(client: Models.ClientObject) -> void:
	print("[GLOBAL] handle_new_client_accepted")
	game_state.clients.append(client)

func handle_client_send_task(_task: Task) -> void:
	print("[GLOBAL] handle_client_send_task")
	game_state.task_received += 1

func handle_letter_hit_task(letter: Letter, task: Task) -> void:
	#print("[GLOBAL] handle_letter_hit_task")
	if letter.word_count > task.remaining_words:
		game_state.translated_words += task.remaining_words
	else:
		game_state.translated_words += letter.word_count

func handle_task_finished(_id: int, _value: float) -> void:
	print("[GLOBAL] handle_task_finished")
	game_state.task_finished += 1
	game_state.reputation += 0.2
	game_state.stress -= 0.5
	if (game_state.stress < 0):
		game_state.stress = 0
	ui_update.emit()

func handle_update_reputation(value: float) -> void:
	print("[GLOBAL] handle_update_reputation")
	game_state.reputation += value
	ui_update.emit()

func handle_update_stress(value: float) -> void:
	print("[GLOBAL] handle_update_stress")
	game_state.stress += value
	ui_update.emit()

	if game_state.stress >= Config.MAX_STRESS_LEVEL:
		game_over.emit()

func handle_update_quality(value: float) -> void:
	print("[GLOBAL] handle_update_quality")
	game_state.quality += value
	ui_update.emit()

func handle_update_money(value: float) -> void:
	print("[GLOBAL] handle_update_money")
	game_state.money += value
	ui_update.emit()

func handle_update_day_count(value: int) -> void:
	print("[GLOBAL] handle_update_day_count")
	game_state.current_day += value
	ui_update.emit()

func handle_game_over() -> void:
	print("[GLOBAL] handle_game_over")
	for prop in game_state.get_property_list():
		print("game_state.", prop)
		if prop.type == 3:
			print("game_state.", prop.name)

func start_new_game() -> void:
	game_state = Models.State.new()
