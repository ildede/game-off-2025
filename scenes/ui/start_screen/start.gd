extends Node
class_name Start

func _on_start_button_pressed() -> void:
	Global.start_new_game()
	SceneTransition.fade_to_main()
