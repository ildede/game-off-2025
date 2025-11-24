extends Control
class_name GameInformation

var money: float = 0

signal end_of_the_day

func _ready() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.max_value = Global.game_config.max_stress_level
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money
	Global.ui_update.connect(ui_update)

func ui_update() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = state.reputation
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = state.quality
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % state.money

func _on_clock_end_of_the_day() -> void:
	end_of_the_day.emit()
