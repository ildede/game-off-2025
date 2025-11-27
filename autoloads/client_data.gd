extends Node

var clients_data: Array[Models.ClientObject]

func _ready() -> void:
	load_clients_data()

func load_clients_data():
	var file = FileAccess.open("res://data/clients.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.get_data()
			for obj in data["clients"]:
				clients_data.append(dictionary_to_class(obj))
		else:
			push_error("JSON Parse Error: ", json.get_error_message())
	else:
		push_error("Failed to load clients.json")

func get_random_client() -> Models.ClientObject:
	if clients_data.is_empty():
		return create_fallback_client()

	return clients_data[randi() % clients_data.size()]

func create_fallback_client() -> Models.ClientObject:
	var fallback_client = Models.ClientObject.new()
	fallback_client.id = randi()
	fallback_client.name = "TechManual Inc."
	fallback_client.engagement_email = "Looking for ..."
	fallback_client.payment_per_word = 0.04
	fallback_client.payment_terms = "IMMEDIATE"
	fallback_client.client_reliability = 1

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
	rcr_tsk.append(task)
	fallback_client.recurring_tasks = rcr_tsk
	var ext_tsk: Array[Models.ExtemporaneousTaskObject] = []
	fallback_client.extemporaneous_tasks = ext_tsk

	return fallback_client

func dictionary_to_class(obj_in: Dictionary) -> Models.ClientObject:
	var client = Models.ClientObject.new()
	client.id = obj_in.get("id", randi())
	client.name = obj_in.get("name")
	client.engagement_email = obj_in.get("engagement_email")
	client.payment_per_word = obj_in.get("payment_per_word")
	client.payment_terms = obj_in.get("payment_terms")
	client.client_reliability = obj_in.get("client_reliability", 1)

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
