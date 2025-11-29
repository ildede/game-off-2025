extends Control
class_name EventControl

var day: Global.Date
var money_value: float
var display_name: String
var event_type: EventsPanel.EventType

func _ready() -> void:
	$Container/Day.text = "{day} {month}".format(day)
	match event_type:
		EventsPanel.EventType.PAYMENT:
			$EventSprite.play("payment")
			$Container/Label.text = "payment"
			$Container/Value.text = "{0}$".format([money_value])
		EventsPanel.EventType.BILL:
			$EventSprite.play("bill")
			$Container/Label.text = display_name
			$Container/Value.text = "-{0}$".format([money_value])
