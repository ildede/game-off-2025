class_name Models
extends RefCounted

class InvoiceObject:
	var task_id: int
	var client_id: int
	var client_name: String
	var money_value: float
	var payment_terms: String

	func _init(ongoing_task: OngoingTask, client: Models.ClientObject) -> void:
		task_id = ongoing_task.task_id
		client_id = ongoing_task.client_id
		client_name = client.name
		money_value = ongoing_task.total_words * client.payment_per_word
		payment_terms = client.payment_terms

class PendingPayement:
	var due_date: int
	var money_value: float
	var client_name: String

	func _init(day: int, value: float, client: String) -> void:
		due_date = day
		money_value = value
		client_name = client

class State:
	var current_day = 1
	var task_received: int = 0
	var task_finished: int = 0
	var task_failed: int = 0
	var translated_words: int = 0

	var reputation: float = 0
	var quality: float = 30
	var stress: float = 0
	var productivity: int = 0
	var clients: Array[ClientObject] = []
	var money: float = 1200
	var tasks_waiting_to_be_processed: Array[InvoiceObject] = []
	var ongoing_task: Array[Models.OngoingTask] = []
	var pending_payments: Array[PendingPayement] = []
	var bills: Array[BillObject] = []

const _engagement_mails = [
		"Dear resource, we would like to work with you. In general, tasks will come to you following this schedule, but sometimes there may be emergencies or irregular flows.\n{workload}\nRates per word: {price}$\nPayment terms: {invoicing}",
		"Esteemed talent, we want to work together with you. Tasks will usually arrive with this plan, but there can be urgent tasks or days with different timing.\n{workload}\nRates per word: {price}$\nPayment terms: {invoicing}",
		"Hi dear, we are interested in working with you. Tasks should come in this approximate schedule, but there may be sudden requests or days with no tasks.\n{workload}\nRates per word: {price}$\nPayment terms: {invoicing}",
		"Dear individual, we would like to start working with you. Most tasks will follow this schedule, but sometimes there can be emergency tasks or changes in the flow.\n{workload}\nRates per word: {price}$\nPayment terms: {invoicing}",
		"Hi team, we want to collaborate with you. Tasks will normally follow this timeline, but please note there might be urgent tasks or times when the flow is not regular.\n{workload}\nRates per word: {price}$\nPayment terms: {invoicing}"
	]

class ClientObject:
	var is_removed: bool
	var loyalty: float

	var id: int
	var name: String
	var workload: String
	var payment_per_word: float
	var payment_terms: String
	var client_reliability: float
	var custom_email: String
	var public_reputation: PublicReputationObject
	var min_reputation: int

	var recurring_tasks: Array[RecurringTaskObject]
	var extemporaneous_tasks: Array[ExtemporaneousTaskObject]

	func get_task_to_spawn(day: int) -> TaskObject:
		for task in recurring_tasks:
			if task.last_spawn == 0 or (day % task.frequency_days == 0 and task.last_spawn != day):
				task.last_spawn = day
				return task
		for task in extemporaneous_tasks:
			if (task.last_spawn == 0 or task.last_spawn + task.deadline_days < day) and task.spawn_probability > randf():
				task.last_spawn = day
				return task
		return null

	func engagement_email() -> String:
		var pay_terms = ""
		match payment_terms:
			"IMMEDIATE":
				pay_terms = "immediate after receiving the invoice"
			"UPON_RECEIPT":
				pay_terms = "we will pay overnight after receiving the invoice"
			"NET7":
				pay_terms = "7 days after invoice"
			"NET30":
				pay_terms = "30 days after invoice"
			"NET60":
				pay_terms = "60 days after invoice"
			"EOM":
				pay_terms = "At the end of the month"
			"EONM":
				pay_terms = "At the end of next month"

		if not custom_email == "":
			return custom_email
		return _engagement_mails.pick_random().format({
			"workload": workload,
			"price": payment_per_word,
			"invoicing": pay_terms
		})

class PublicReputationObject:
	var on_accept: float

class TaskObject:
	var words: int
	var deadline_days: int
	var reputation_on_success: float
	var reputation_on_failure: float
	var need_confirmation_email: bool
	var last_spawn: int = 0

class RecurringTaskObject:
	extends TaskObject
	var frequency_days: int

class ExtemporaneousTaskObject:
	extends TaskObject
	var spawn_probability: float

class OngoingTask:
	var task_id: int
	var client_id: int

	var total_words: int
	var remaining_words: int
	var assigned_on: int
	var deadline_days: int

	var reputation_on_success: float
	var reputation_on_failure: float

	func _init(cl_id: int, task: TaskObject):
		task_id = randi()
		client_id = cl_id

		var variation = roundi(task.words * 0.05)
		var actual_words = task.words + randi_range(-variation, +variation)
		total_words = actual_words
		remaining_words = actual_words
		assigned_on = Global.game_state.current_day
		deadline_days = task.deadline_days
		reputation_on_success = task.reputation_on_success
		reputation_on_failure = task.reputation_on_failure

class BillObject:
	var id: int
	var name: String
	var amount: float
	var due_day: int
	var next_payment_day: int
	var recurring: bool

class EventObject:
	var id: int
	var name: String
	var description: String
	var can_spawn: bool

class BonusObject:
	var id: int
	var name: String
	var description: String
	var can_spawn: bool
	var cost: float
	var quality_change: float
	var stress_change: float
	var reputation_change: float
	var default_bill_change: float
	var productivity_change: int
	
