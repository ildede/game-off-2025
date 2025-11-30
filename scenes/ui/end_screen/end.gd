extends Node
class_name End

func _ready() -> void:
	print("[END] _ready")
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/GridContainer/MarginContainer/Title.text = ""
	if Global.game_state.stress >= 0:
		$Panel/GridContainer/MarginContainer/Title.append_text("BURNOUT!")
	if Global.game_state.money < 0:
		$Panel/GridContainer/MarginContainer/Title.append_text("NOT ENOUGH MONEY!".format([Global.game_state.current_day]))

	$Panel/GridContainer/Description.text = ""
	$Panel/GridContainer/Description.append_text("Too bad :(  you are too weak to survive in such an unfair and unlucky job.\n
	But if you are masochistic enough and you still want more, you can TRY AGAIN
Or you can GIVE UP and work on that small backup plan of yours for a ")
	var backup_plan = ["TEA ROOM", "BOOKSTORE", "CAFETERIA", "CAT CAFE"]
	$Panel/GridContainer/Description.append_text(backup_plan.pick_random())

	$Panel/GridContainer/Statistics.text = ""
	$Panel/GridContainer/Statistics.append_text("Days survived: {0}
Translated words: {1}
You'll be missed by {2} clients".format([
		Global.game_state.current_day,
		Global.game_state.translated_words,
		Global.game_state.clients.filter(func(c: Models.ClientObject): return not c.is_removed).size()
	]))

func _on_try_again_pressed() -> void:
	print("[END] _on_try_again_pressed")
	Global.start_new_game()
	SceneTransition.fade_to_main()

func _on_quit_pressed() -> void:
	print("[END] _on_quit_pressed")
	get_tree().quit()
