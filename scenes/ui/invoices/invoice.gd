extends Node2D
class_name Invoice

signal invoice_clicked()

var amount: int = 0

func _ready():
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled() 
		invoice_clicked.emit()
