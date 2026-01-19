extends Node

signal new_client_accepted(client_info: Models.ClientObject)
signal client_send_task(task: Task)
signal letter_hit_task(letter: Letter, task: Task)
signal new_priority_task(task: Task)
signal client_deleted(id: int)
signal qworse_acquires(id: int)
signal task_deleted(id: int)
signal task_finished(id: int)
signal task_failed(id: int)
signal update_reputation(value: float)
signal update_productivity(value: int)
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
	task_failed.connect(handle_task_failed)
	task_deleted.connect(handle_task_deleted)
	update_reputation.connect(handle_update_reputation)
	update_productivity.connect(handle_update_productivity)
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
	game_state.reputation += client.public_reputation.on_accept

func handle_client_send_task(_task: Task) -> void:
	print("[GLOBAL] handle_client_send_task")
	ui_update.emit()

func handle_letter_hit_task(letter: Letter, task: Task) -> void:
	#print("[GLOBAL] handle_letter_hit_task")
	if letter.word_count > task.remaining_words:
		game_state.translated_words += task.remaining_words
	else:
		game_state.translated_words += letter.word_count

func handle_task_finished(_id: int) -> void:
	print("[GLOBAL] handle_task_finished")
	game_state.task_finished += 1
	game_state.quality += 0.1
	ui_update.emit()

func handle_task_failed(_id: int) -> void:
	print("[GLOBAL] handle_task_failed")
	game_state.task_failed += 1
	game_state.quality -= 0.2
	ui_update.emit()

func handle_task_deleted(_id: int) -> void:
	print("[GLOBAL] handle_task_deleted")
	ui_update.emit()

func handle_update_reputation(value: float) -> void:
	print("[GLOBAL] handle_update_reputation")
	game_state.reputation += value
	if (game_state.reputation < 0):
		game_state.reputation = 0
	if (game_state.reputation > Config.MAX_REPUTATION_LEVEL):
		game_state.reputation = Config.MAX_REPUTATION_LEVEL
	ui_update.emit()

func handle_update_productivity(value: int) -> void:
	print("[GLOBAL] handle_update_productivity")
	game_state.productivity += value
	if (game_state.productivity < 0):
		game_state.productivity = 0
	ui_update.emit()

func handle_update_stress(value: float) -> void:
	print("[GLOBAL] handle_update_stress")
	game_state.stress += value
	if (game_state.stress < 0):
		game_state.stress = 0
	if (game_state.stress > Config.MAX_STRESS_LEVEL):
		game_state.stress = Config.MAX_STRESS_LEVEL
	ui_update.emit()

	if game_state.stress >= Config.MAX_STRESS_LEVEL:
		game_over.emit()

func handle_update_quality(value: float) -> void:
	print("[GLOBAL] handle_update_quality")
	game_state.quality += value
	if (game_state.quality < 0):
		game_state.quality = 0
	if (game_state.quality > Config.MAX_QUALITY_LEVEL):
		game_state.quality = Config.MAX_QUALITY_LEVEL
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

func start_old_game() -> void:
	const SAVE_PATH = "user://save_config_file.ini"
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	game_state = Models.State.new()
	game_state.current_day = config.get_value("game_state", "current_day")
	game_state.task_received = config.get_value("game_state", "task_received")
	game_state.task_finished = config.get_value("game_state", "task_finished")
	game_state.task_failed = config.get_value("game_state", "task_failed")
	game_state.translated_words = config.get_value("game_state", "translated_words")
	game_state.reputation = config.get_value("game_state", "reputation")
	game_state.quality = config.get_value("game_state", "quality")
	game_state.stress = config.get_value("game_state", "stress")
	game_state.productivity = config.get_value("game_state", "productivity")
	game_state.money = config.get_value("game_state", "money")
	game_state.mechanical_keyboard = config.get_value("game_state", "mechanical_keyboard")

	#var clients: Array[ClientObject] = []
	#var tasks_waiting_to_be_processed: Array[InvoiceObject] = []
	#var ongoing_task: Array[Models.OngoingTask] = []
	#var pending_payments: Array[PendingPayement] = []
	#var bills: Array[BillObject] = []

	ClientData.load_json_data()
	game_state.bills = ClientData.bills_data.duplicate()

func start_new_game() -> void:
	game_state = Models.State.new()
	game_state.productivity = Config.WORDS_PER_DAY
	ClientData.load_json_data()
	game_state.bills = ClientData.bills_data.duplicate()

class Date:
	var day: String
	var month: String
	func _init(d: int, m: String) -> void:
		day = Global.to_ordinal_day(d)
		month = m

func get_current_date() -> Date:
	return day_number_to_date(game_state.current_day)

func day_number_to_date(day_number: int) -> Date:
	var day_to_look_for = day_number
	if day_to_look_for < 1: day_to_look_for = 1
	if day_to_look_for > 365: day_to_look_for = day_to_look_for % 365

	var months = [
		{"name": "Jan", "days": 31},
		{"name": "Feb", "days": 28},
		{"name": "Mar", "days": 31},
		{"name": "Apr", "days": 30},
		{"name": "May", "days": 31},
		{"name": "Jun", "days": 30},
		{"name": "Jul", "days": 31},
		{"name": "Aug", "days": 31},
		{"name": "Sep", "days": 30},
		{"name": "Oct", "days": 31},
		{"name": "Nov", "days": 30},
		{"name": "Dec", "days": 31}
	]
	var remaining_days = day_to_look_for
	for month in months:
		if remaining_days <= month.days:
			return Date.new(remaining_days, month.name)
		remaining_days -= month.days
	return Date.new(1, "Jan")

func to_ordinal_day(day: int) -> String:
	match day:
		1, 21, 31:
			return "{0}st".format([day])
		2, 22:
			return "{0}nd".format([day])
		3, 23:
			return "{0}rd".format([day])
	return "{0}th".format([day])

func until_end_of_month(day_number: int) -> int:
	var day_to_look_for = day_number
	if day_to_look_for < 1: day_to_look_for = 1
	if day_to_look_for > 365: day_to_look_for = day_to_look_for % 365
	var month_ends = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
	for end_day in month_ends:
		if day_to_look_for <= end_day:
			return end_day - day_to_look_for
	return 1
