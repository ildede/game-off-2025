extends AnimatedSprite2D
class_name EventSprite

var day: Global.Date
var display_name: String
var event_type: EventsPanel.EventType

func _ready() -> void:
	$Day.text = "{day} {month}".format(day)
	$Name.text = display_name
	print("_ready", display_name, event_type)
	match event_type:
		EventsPanel.EventType.PAYMENT:
			play("payment")
		EventsPanel.EventType.BILL:
			play("bill")
