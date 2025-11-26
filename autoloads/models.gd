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
	var clients: Array[Dictionary] = []
	var money: float = 0
	var tasks_waiting_to_be_processed: Array[InvoiceObject] = []
