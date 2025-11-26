class_name Models
extends RefCounted

class InvoiceObject:
	var task_id: int
	var money_value: float

	func _init(id: int, value: float) -> void:
		task_id = id
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
	var money: float = 0
	var tasks_waiting_to_be_processed: Array[InvoiceObject] = []

class ClientObject:
	var id: int
	var name: String
	var engagement_email: String
	var payment_per_word: float
	var client_reliability: float

	var public_reputation: PublicReputationObject
	var loyalty_meter: LoyaltyMeterObject

	var recurring_tasks: Array[RecurringTaskObject]
	var extemporaneous_tasks: Array[ExtemporaneousTaskObject]

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
	var payment_terms: String
	var reputation_on_success: float
	var reputation_on_failure: float
	var loyalty_on_success: float
	var loyalty_on_failure: float

class RecurringTaskObject:
	extends TaskObject
	var frequency_days: int

class ExtemporaneousTaskObject:
	extends TaskObject
	var spawn_probability: int
