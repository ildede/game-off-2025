extends Node
class_name End

func _ready() -> void:
	print("[END] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_start_button_pressed() -> void:
	print("[END] _on_start_button_pressed")
	Global.start_new_game()
	SceneTransition.fade_to_main()
