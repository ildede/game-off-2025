extends Node
class_name Start


func _ready() -> void:
	print("[START] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	const SAVE_PATH = "user://save_config_file.ini"
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	var old_day = config.get_value("game_state", "current_day")
	if old_day != null and old_day > 1:
		$Panel/GridContainer/GridContainer/ContinueButton.text = "CONTINUE DAY " + str(old_day)
		$Panel/GridContainer/GridContainer/ContinueButton.visible = true


func _on_start_button_pressed() -> void:
	print("[START] _on_start_button_pressed")
	Global.start_new_game()
	SceneTransition.fade_to_main()

func _on_continue_button_pressed() -> void:
	print("[START] _on_continue_button_pressed")
	Global.start_old_game()
	SceneTransition.fade_to_new_day()
