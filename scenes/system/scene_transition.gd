extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$ColorRect.visible = false

func fade_to_main() -> void:
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished

	get_tree().change_scene_to_file("res://scenes/ui/main_screen/main.tscn")

	await get_tree().process_frame

	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false

func fade_to_new_day(callback: Callable) -> void:
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished

	callback.call()

	await get_tree().process_frame

	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	$ColorRect.visible = false
