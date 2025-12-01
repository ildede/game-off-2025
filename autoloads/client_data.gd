extends Node

var clients_data: Array[Models.ClientObject]
var bills_data: Array[Models.BillObject]
var events_data: Array[Models.EventObject]
var bonus_data: Array[Models.BonusObject]

func _ready() -> void:
	print("[CLIENT_DATA] ready")
	load_json_data()

func load_json_data():
	var file = FileAccess.open("res://data/game_data.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.get_data()
			for obj in data["clients"]:
				clients_data.append(dictionary_to_client(obj))
			for obj in data["bills"]:
				bills_data.append(dictionary_to_bill(obj))
			for obj in data["events"]:
				events_data.append(dictionary_to_event(obj))
			for obj in data["bonus"]:
				bonus_data.append(dictionary_to_bonus(obj))
		else:
			push_error("JSON Parse Error: ", json.get_error_message())
	else:
		push_error("Failed to load clients.json")

func client_accepted(client_id: int) -> void:
	var found_index = clients_data.find_custom(func(c): return c.id == client_id);
	if found_index >= 0:
		clients_data.remove_at(found_index)

func get_random_client() -> Models.ClientObject:
	if clients_data.is_empty():
		return create_fallback_client()
	
	var tmp = clients_data.filter(func(c): return c.min_reputation <= Global.game_state.reputation)
	return tmp[randi() % tmp.size()]

func get_random_event() -> Models.EventObject:
	if events_data.is_empty():
		return create_fallback_event()

	return events_data.filter(func(e):return e.can_spawn).pick_random()

func get_random_bonus() -> Models.BonusObject:
	return bonus_data.filter(func(e):return e.can_spawn).pick_random()

func create_fallback_event() -> Models.EventObject:
	var fallback_event = Models.EventObject.new()
	fallback_event.id = randi()
	fallback_event.name = "Routine Work"
	fallback_event.description = "Standard translation tasks keep you busy. Nothing extraordinary, just steady progress."
	fallback_event.can_spawn = true

	return fallback_event

func create_fallback_client() -> Models.ClientObject:
	var fallback_client = Models.ClientObject.new()
	fallback_client.id = randi()
	fallback_client.name = "TechManual Inc."
	fallback_client.workload = "We send 200 words daily!"
	fallback_client.payment_per_word = 0.04
	fallback_client.payment_terms = "UPON_RECEIPT"
	fallback_client.client_reliability = 1
	fallback_client.loyalty = Config.MAX_CLIENT_LOYALTY

	var pb_rep = Models.PublicReputationObject.new()
	pb_rep.on_accept = 2
	pb_rep.on_task_success = 0.5
	pb_rep.on_task_failure = -0.5
	fallback_client.public_reputation = pb_rep

	var lyt_mtr = Models.LoyaltyMeterObject.new()
	lyt_mtr.on_task_success = 0.5
	lyt_mtr.on_task_failure = -0.5
	lyt_mtr.breakup_point = -10
	fallback_client.loyalty_meter = lyt_mtr

	var rcr_tsk: Array[Models.RecurringTaskObject] = []
	var task: Models.RecurringTaskObject = Models.RecurringTaskObject.new()
	task.frequency_days = 1
	task.words = 200
	task.deadline_days = 1
	task.on_task_success = 10.0
	task.on_task_failure = -10.0
	task.need_confirmation_email = false
	rcr_tsk.append(task)
	fallback_client.recurring_tasks = rcr_tsk
	var ext_tsk: Array[Models.ExtemporaneousTaskObject] = []
	fallback_client.extemporaneous_tasks = ext_tsk

	return fallback_client

func dictionary_to_client(obj_in: Dictionary) -> Models.ClientObject:
	var client = Models.ClientObject.new()
	client.is_removed = false
	client.id = obj_in.get("id", randi())
	client.name = obj_in.get("name")
	client.workload = obj_in.get("workload", "")
	client.payment_per_word = obj_in.get("payment_per_word")
	client.payment_terms = obj_in.get("payment_terms")
	client.custom_email = obj_in.get("custom_email", "")
	client.client_reliability = obj_in.get("client_reliability", 1)
	client.min_reputation = obj_in.get("min_reputation", 0)
	client.loyalty = Config.MAX_CLIENT_LOYALTY

	var rcr_tsk: Array[Models.RecurringTaskObject] = []
	for task_in in obj_in["recurring_tasks"]:
		var task: Models.RecurringTaskObject = Models.RecurringTaskObject.new()
		task.frequency_days = task_in.get("frequency_days")
		task.words = task_in.get("words")
		task.deadline_days = task_in.get("deadline_days")
		task.reputation_on_success = task_in.get("reputation_on_success", 0)
		task.reputation_on_failure = task_in.get("reputation_on_failure", 0)
		task.loyalty_on_success = task_in.get("loyalty_on_success", 0)
		task.loyalty_on_failure = task_in.get("loyalty_on_failure", 0)
		task.need_confirmation_email = task_in.get("need_confirmation_email", false)
		rcr_tsk.append(task)
	client.recurring_tasks = rcr_tsk

	var ext_tsk: Array[Models.ExtemporaneousTaskObject] = []
	for task_in in obj_in["extemporaneous_tasks"]:
		var task: Models.ExtemporaneousTaskObject = Models.ExtemporaneousTaskObject.new()
		task.spawn_probability = task_in.get("spawn_probability")
		task.words = task_in.get("words")
		task.deadline_days = task_in.get("deadline_days")
		task.reputation_on_success = task_in.get("reputation_on_success", 0)
		task.reputation_on_failure = task_in.get("reputation_on_failure", 0)
		task.loyalty_on_success = task_in.get("loyalty_on_success", 0)
		task.loyalty_on_failure = task_in.get("loyalty_on_failure", 0)
		task.need_confirmation_email = task_in.get("need_confirmation_email", true)
		ext_tsk.append(task)
	client.extemporaneous_tasks = ext_tsk

	var pb_rep = Models.PublicReputationObject.new()
	pb_rep.on_accept = obj_in["public_reputation"].get("on_accept", 0)
	pb_rep.on_task_success = obj_in["public_reputation"].get("on_task_success", 0)
	pb_rep.on_task_failure = obj_in["public_reputation"].get("on_task_failure", 0)
	client.public_reputation = pb_rep

	var lyt_mtr = Models.LoyaltyMeterObject.new()
	lyt_mtr.on_task_success = obj_in["loyalty_meter"].get("on_task_success", 0)
	lyt_mtr.on_task_failure = obj_in["loyalty_meter"].get("on_task_failure", 0)
	lyt_mtr.breakup_point = obj_in["loyalty_meter"].get("breakup_point", -1)
	client.loyalty_meter = lyt_mtr

	return client

func dictionary_to_bill(obj_in: Dictionary) -> Models.BillObject:
	var bill = Models.BillObject.new()
	bill.id = obj_in.get("id")
	bill.name = obj_in.get("name")
	bill.amount = obj_in.get("amount")
	bill.due_day = obj_in.get("due_day")
	bill.next_payment_day = bill.due_day
	bill.recurring = obj_in.get("recurring")

	return bill

func dictionary_to_event(obj_in: Dictionary) -> Models.EventObject:
	var event = Models.EventObject.new()
	event.id = obj_in.get("id")
	event.name = obj_in.get("name")
	event.description = obj_in.get("description")
	event.can_spawn = obj_in.get("can_spawn")

	return event

func dictionary_to_bonus(obj_in: Dictionary) -> Models.BonusObject:
	var event = Models.BonusObject.new()
	event.id = obj_in.get("id")
	event.name = obj_in.get("name")
	event.description = obj_in.get("description")
	event.can_spawn = obj_in.get("can_spawn")

	return event
