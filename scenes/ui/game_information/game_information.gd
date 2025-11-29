extends Control
class_name GameInformation

@onready var events_panel: EventsPanel = $EventsPanel

func _ready() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.max_value = Config.MAX_STRESS_LEVEL
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money
	var events: Array[EventsPanel.Event] = []
	for bill: Models.BillObject in state.bills:
		events.append(EventsPanel.Event.new(EventsPanel.EventType.BILL, bill.next_payment_day, bill.amount, bill.name))
	for payement: Models.PendingPayement in state.pending_payments:
		events.append(EventsPanel.Event.new(EventsPanel.EventType.PAYMENT, payement.due_date, payement.money_value, payement.client_name))
	events_panel.update_events(events)
	Global.ui_update.connect(ui_update)

func ui_update() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money
	var events: Array[EventsPanel.Event] = []
	for bill: Models.BillObject in state.bills:
		events.append(EventsPanel.Event.new(EventsPanel.EventType.BILL, bill.next_payment_day, bill.amount, bill.name))
	for payement: Models.PendingPayement in state.pending_payments:
		events.append(EventsPanel.Event.new(EventsPanel.EventType.PAYMENT, payement.due_date, payement.money_value, payement.client_name))
	events_panel.update_events(events)
