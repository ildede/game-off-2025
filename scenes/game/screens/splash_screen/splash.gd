extends Node
class_name Splash

func _ready() -> void:
	print("[SPLASH] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_start_button_pressed() -> void:
	print("[SPLASH] _on_start_button_pressed")
	SceneTransition.fade_to_start()
