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
	if Global.game_state.ongoing_task.is_empty():
		$ClockAndButtons/Buttons/DayOff.disabled = false
		$ClockAndButtons/Buttons/Holiday.disabled = false
	else:
		$ClockAndButtons/Buttons/DayOff.disabled = true
		$ClockAndButtons/Buttons/Holiday.disabled = true

func dispaly_holiday_message():
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "Do you want to go on holiday?"
	var message_lines: Array[String] = [
		"Today is {day} {month}, an holiday is waiting".format(Global.get_current_date()),
		"You'll be back to work again at {day} {month}".format(Global.day_number_to_date(Global.game_state.current_day+7))
	]
	popup_data.lines = message_lines

	var accept_button = CustomizablePopupMessage.PopupButton.new()
	accept_button.text = "YES"
	accept_button.action = func():
		Global.game_state.current_day += 6
		Global.game_clock.start(0.01)
		get_tree().paused = false

	var postpone_button = CustomizablePopupMessage.PopupButton.new()
	postpone_button.text = "NO"
	postpone_button.action = func():
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_button, postpone_button]
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false
	$CustomPopupMessage.show_popup(popup_data)

func dispaly_dayoff_message():
	get_tree().paused = true
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "Do you want to go on holiday?"
	var message_lines: Array[String] = [
		"Today is {day} {month}, a Day off is waiting".format(Global.get_current_date()),
		"You'll be back to work again at {day} {month}".format(Global.day_number_to_date(Global.game_state.current_day+2))
	]
	popup_data.lines = message_lines

	var accept_button = CustomizablePopupMessage.PopupButton.new()
	accept_button.text = "YES"
	accept_button.action = func():
		Global.game_state.current_day += 1
		Global.game_clock.start(0.01)
		get_tree().paused = false

	var postpone_button = CustomizablePopupMessage.PopupButton.new()
	postpone_button.text = "NO"
	postpone_button.action = func():
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_button, postpone_button]
	popup_data.buttons = btns
	popup_data.on_close = func(): get_tree().paused = false
	$CustomPopupMessage.show_popup(popup_data)
