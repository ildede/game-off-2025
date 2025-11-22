extends Node2D
class_name Main

@onready var popup_message: PopupMessage = $PopupMessage

@onready var client_data: ClientData = preload("res://scenes/game/entities/client/client_data.gd").new()
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")

func _ready() -> void:
	popup_message.new_client_accepted.connect(_on_accept_pressed)
	popup_message.new_client_refused.connect(_on_refuse_pressed)
	add_child(client_data)

func new_email_from_client() -> void:
	var client_info = client_data.get_random_client()
	popup_message.show_popup(client_info)

func add_new_client(client_info: Dictionary) -> void:
	var client: Client = client_scene.instantiate()
	var screen = get_visible_screen()
	var client_position = Vector2(randi_range(500, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position, client_info)
	add_child(client)

func get_visible_screen() -> Vector2:
	return get_viewport().get_visible_rect().size

func _on_refuse_pressed() -> void:
	_on_ask_new_client_close_requested()

func _on_accept_pressed(client_info: Dictionary) -> void:
	Global.update_reputation.emit(1)
	add_new_client(client_info)
	_on_ask_new_client_close_requested()

func _on_ask_new_client_close_requested() -> void:
	$EventSpawner.start(31.0)
	$PopupMessage.hide()

func _on_ask_new_client_about_to_popup() -> void:
	$EventSpawner.stop()
