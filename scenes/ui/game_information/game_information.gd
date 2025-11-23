extends Control
class_name GameInformation

var money: float = 0

signal end_of_the_day

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value = 0
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value = 50
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = 5
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % money
	Global.update_reputation.connect(reputation_change)
	Global.update_stress.connect(stress_change)
	Global.update_quality.connect(quality_change)
	Global.update_money.connect(money_change)

func reputation_change(value):
	$InfoPanel/MarginContainer/GridContainer/ReputationLabel/ReputationBar.value += value

func stress_change(value):
	$InfoPanel/MarginContainer/GridContainer/StressLabel/StressBar.value += value

func quality_change(value):
	$InfoPanel/MarginContainer/GridContainer/QualityLabel/QualityBar.value += value

func money_change(value):
	money += value
	$InfoPanel/MarginContainer/GridContainer/GridContainer/Money.text = "%.2f" % money

func _on_clock_end_of_the_day() -> void:
	end_of_the_day.emit()

func update_day_count(days: int) -> void:
	$Clock.update_day_count(days)
