extends PanelContainer
class_name EventsPanel

@onready var event_scene = preload("res://scenes/ui/events_panel/event.tscn")

var childs = []

func _ready() -> void:
	print("")

func update_events(ar: Array[Event]):
	for c in childs:
		c.queue_free()
	childs.clear()
	ar.sort_custom(func(a, b): return a.day < b.day)
	var count = 0
	for e in ar:
		var ev_instance: EventSprite = event_scene.instantiate()
		ev_instance.day = Global.day_number_to_date(e.day)
		ev_instance.display_name = e.name
		ev_instance.event_type = e.type
		ev_instance.position = self.global_position + Vector2(-380 + (120 * count), 150)
		add_child(ev_instance)
		childs.append(ev_instance)
		count += 1

enum EventType {
	PAYMENT,
	BILL
}

class Event:
	var day: int
	var type: EventType
	var amount: float
	var name: String
	func _init(type_, day_, amount_, name_) -> void:
		type = type_
		day = day_
		amount = amount_
		name = name_
