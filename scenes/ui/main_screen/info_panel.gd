extends PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/GridContainer/StressLabel/StressBar.value = 0
	$MarginContainer/GridContainer/QualityLabel/QualityBar.value = 50
	$MarginContainer/GridContainer/ReputationLabel/ReputationBar.value = 5
	Global.update_reputation.connect(reputation_change)
	Global.update_stress.connect(stress_change)
	Global.update_quality.connect(quality_change)

func reputation_change(value):
	$MarginContainer/GridContainer/ReputationLabel/ReputationBar.value += value

func stress_change(value):
	$MarginContainer/GridContainer/StressLabel/StressBar.value += value

func quality_change(value):
	$MarginContainer/GridContainer/QualityLabel/QualityBar.value += value
