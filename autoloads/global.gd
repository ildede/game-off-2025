extends Node

signal new_client_accepted(client_info: Dictionary)
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

@onready var game_state: State = State.new()
@onready var game_config: Config = Config.new()

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

func handle_new_client_accepted(client_info: Dictionary) -> void:
	print("[GLOBAL] handle_new_client_accepted")
	game_state.clients.append(client_info)

func handle_client_send_task(_task: Task) -> void:
	print("[GLOBAL] handle_client_send_task")
	game_state.task_received += 1

func handle_letter_hit_task(letter: Letter, task: Task) -> void:
	#print("[GLOBAL] handle_letter_hit_task")
	if letter.word_count > task.remaining_words:
		game_state.translated_words += task.remaining_words
	else:
		game_state.translated_words += letter.word_count

func handle_task_finished(id: int, value: float) -> void:
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

	if game_state.stress >= game_config.max_stress_level:
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
	game_state = State.new()

class Config:
	var day_lenght_in_seconds: float = 60
	var seconds_between_events: int = 20
	var words_per_letter: int = 11
	var max_stress_level: float = 100
	var words_per_day: int = 2500

class State:
	var current_day = 1
	var task_received: int = 0
	var task_finished: int = 0
	var translated_words: int = 0

	var reputation: float = 0
	var quality: float = 50
	var stress: float = 0
	var clients: Array[Dictionary] = []
	var money: float = 0
	var tasks_waiting_to_be_processed: Array[InvoiceObject] = []

class InvoiceObject:
	var task_id: int
	var money_value: float
	
	func _init(id: int, value: float) -> void:
		task_id = id
		money_value = value
