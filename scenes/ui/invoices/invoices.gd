extends Node2D
class_name Invoices

var invoice = preload("res://scenes/ui/invoices/invoice.tscn")
var waiting_to_be_processed: Array[_Invoice] = []
var child_added = []

class _Invoice:
	var task_id: int
	var money_value: float
	
	func _init(id: int, value: float) -> void:
		task_id = id
		money_value = value

func _ready() -> void:
	Global.task_finished.connect(add_invoice)

func add_invoice(id: int, value: float):
	print("add_invoice {id} ${value}".format({"id":id,"value":value}))
	var created = _Invoice.new(id, value)
	var new_invoice = invoice.instantiate()
	new_invoice.position = self.global_position + Vector2(randi_range(-50,50), -(waiting_to_be_processed.size()*100))
	waiting_to_be_processed.append(created)
	child_added.append(new_invoice)
	add_child(new_invoice)
	new_invoice.invoice_clicked.connect(_on_single_invoice_clicked)

func _on_single_invoice_clicked():
	print("[Invoices] _on_single_invoice_clicked, collecting everything")
	var total = waiting_to_be_processed.reduce(func(acc, element): return acc + element.money_value, 0)
	Global.update_money.emit(total)
	waiting_to_be_processed.clear()
	for child in child_added:
		child.queue_free()
	child_added.clear()

#func sum_invoce_amount(accum: float, element: _Invoice) -> float:
	#return accum + element.money_value
