extends Control
class_name GameInformation

func _ready() -> void:
	var state = Global.game_state
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = state.stress
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.max_value = Config.MAX_STRESS_LEVEL
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
