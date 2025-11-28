class_name Models
extends RefCounted

class InvoiceObject:
	var task_id: int
	var client_id: int
	var money_value: float
	var payment_terms: String

	func _init(ongoing_task: OngoingTask, client: Models.ClientObject) -> void:
		task_id = ongoing_task.task_id
		client_id = ongoing_task.client_id
		money_value = ongoing_task.total_words * client.payment_per_word
		payment_terms = client.payment_terms

class PendingPayement:
	var due_date: int
	var money_value: float

	func _init(day: int, value: float) -> void:
		due_date = day
		money_value = value

class State:
	var current_day = 1
	var task_received: int = 0
	var task_finished: int = 0
	var translated_words: int = 0

	var reputation: float = 0
	var quality: float = 50
	var stress: float = 0
	var clients: Array[ClientObject] = []
	var money: float = 100
	var tasks_waiting_to_be_processed: Array[InvoiceObject] = []
	var ongoing_task: Array[Models.OngoingTask] = []
	var pending_payments: Array[PendingPayement] = []

class ClientObject:
	var id: int
	var name: String
	var engagement_email: String
	var payment_per_word: float
	var payment_terms: String
	var client_reliability: float

	var public_reputation: PublicReputationObject
	var loyalty: float
	var loyalty_meter: LoyaltyMeterObject

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

class PublicReputationObject:
	var on_accept: float
	var on_task_success: float
	var on_task_failure: float

class LoyaltyMeterObject:
	var on_task_success: float
	var on_task_failure: float
	var breakup_point: float

class TaskObject:
	var words: int
	var deadline_days: int
	var reputation_on_success: float
	var reputation_on_failure: float
	var loyalty_on_success: float
	var loyalty_on_failure: float
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
	var loyalty_on_success: float
	var loyalty_on_failure: float

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
		loyalty_on_success = task.loyalty_on_success
		loyalty_on_failure = task.loyalty_on_failure
