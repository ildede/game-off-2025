extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$ColorRect.visible = false

func fade_to_main() -> void:
	black_fade_in()
	get_tree().change_scene_to_file("res://scenes/ui/main_screen/main.tscn")
	black_fade_out()

func fade_to_new_day(callback: Callable) -> void:
	black_fade_in()
	callback.call()
	black_fade_out()

func fade_to_end() -> void:
	black_fade_in()
	get_tree().change_scene_to_file("res://scenes/ui/end_screen/end.tscn")
	black_fade_out()

func black_fade_in() -> void:
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished

func black_fade_out() -> void:
	await get_tree().process_frame
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false
