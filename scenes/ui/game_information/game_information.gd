extends Control
class_name GameInformation

func _ready() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.max_value = Config.MAX_STRESS_LEVEL
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money

	$FuturePanel/MarginContainer/GridContainer/NextBills.append_text("Bills")
	var bills = state.bills.duplicate()
	bills.sort_custom(func(a, b): return a.next_payment_day < b.next_payment_day)
	for bill: Models.BillObject in bills:
		var day_of_payement = Global.day_number_to_date(bill.next_payment_day)
		$FuturePanel/MarginContainer/GridContainer/NextBills.newline()
		$FuturePanel/MarginContainer/GridContainer/NextBills.append_text("{0} {1}: {2} {3}$".format([day_of_payement.day, day_of_payement.month, bill.name, bill.amount]))

	$FuturePanel/MarginContainer/GridContainer/NextPayment.append_text("Payments")
	var payments = state.pending_payments
	payments.sort_custom(func(a, b): return a.due_date < b.due_date)
	for payement: Models.PendingPayement in payments:
		var day_of_payement = Global.day_number_to_date(payement.due_date)
		$FuturePanel/MarginContainer/GridContainer/NextPayment.newline()
		$FuturePanel/MarginContainer/GridContainer/NextPayment.append_text("{0} {1}: {2}$".format([day_of_payement.day, day_of_payement.month, payement.money_value]))
	Global.ui_update.connect(ui_update)

func ui_update() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money

	$FuturePanel/MarginContainer/GridContainer/NextBills.clear()
	$FuturePanel/MarginContainer/GridContainer/NextBills.append_text("Bills")
	var bills = state.bills.duplicate()
	bills.sort_custom(func(a, b): return a.next_payment_day < b.next_payment_day)
	for bill: Models.BillObject in bills:
		var day_of_payement = Global.day_number_to_date(bill.next_payment_day)
		$FuturePanel/MarginContainer/GridContainer/NextBills.newline()
		$FuturePanel/MarginContainer/GridContainer/NextBills.append_text("{0} {1}: {2} {3}$".format([day_of_payement.day, day_of_payement.month, bill.name, bill.amount]))

	$FuturePanel/MarginContainer/GridContainer/NextPayment.clear()
	$FuturePanel/MarginContainer/GridContainer/NextPayment.append_text("Payments")
	var payments = state.pending_payments
	payments.sort_custom(func(a, b): return a.due_date < b.due_date)
	for payement: Models.PendingPayement in payments:
		var day_of_payement = Global.day_number_to_date(payement.due_date)
		$FuturePanel/MarginContainer/GridContainer/NextPayment.newline()
		$FuturePanel/MarginContainer/GridContainer/NextPayment.append_text("{0} {1}: {2}$".format([day_of_payement.day, day_of_payement.month, payement.money_value]))
