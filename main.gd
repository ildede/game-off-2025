extends Node2D

const client_scene = preload("res://client/client.tscn")

func new_email_from_client() -> void:
	$AskNewClient.popup_centered()

func add_new_client() -> void:
	var client = client_scene.instantiate()
	var screen = get_visible_screen()
	var client_position = Vector2(randi_range(500, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position)
	add_child(client)

func get_visible_screen() -> Vector2:
	return get_viewport().get_visible_rect().size

func _on_refuse_pressed() -> void:
	_on_ask_new_client_close_requested()

func _on_accept_pressed() -> void:
	GlobalSignal.update_reputation.emit(1)
	add_new_client()
	_on_ask_new_client_close_requested()

func _on_ask_new_client_close_requested() -> void:
	$NewClient.start(5.0)
	$AskNewClient.visible = false

func _on_ask_new_client_about_to_popup() -> void:
	$NewClient.stop()
