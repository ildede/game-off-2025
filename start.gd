extends Node
class_name Start

func _on_start_button_pressed() -> void:
	print("start_button pressed")
	SceneTransition.fade_to_main()
