extends Node2D
class_name Main

@onready var popup_message: PopupMessage = $PopupMessage
@onready var game_information: GameInformation = $GameInformation

@onready var client_data: ClientData = preload("res://scenes/game/entities/client/client_data.gd").new()
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")

func _ready() -> void:
	popup_message.new_client_accepted.connect(handle_accepted_client)
	popup_message.new_client_refused.connect(handle_refused_client)
	popup_message.popup_closed.connect(handle_closing_popup)
	game_information.end_of_the_day.connect(handle_end_of_the_day)
	add_child(client_data)

func new_email_from_client() -> void:
	var client_info = client_data.get_random_client()
	get_tree().paused = true
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

func handle_accepted_client(client_info: Dictionary) -> void:
	Global.update_reputation.emit(1)
	add_new_client(client_info)
	handle_closing_popup()

func handle_refused_client() -> void:
	handle_closing_popup()

func handle_closing_popup() -> void:
	$EventSpawner.start(31.0)
	$PopupMessage.hide()
	get_tree().paused = false

func handle_end_of_the_day() -> void:
	print("The end is nay")
	get_tree().paused = true
	print("nope or yes?")
	SceneTransition.fade_to_new_day(func callback():
		print("daje")
		game_information.update_day_count(1)
		get_tree().paused = false)
