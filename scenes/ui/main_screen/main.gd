extends Node2D
class_name Main

@onready var popup_message: PopupMessage = $PopupMessage
@onready var game_information: GameInformation = $GameInformation

@onready var client_data: ClientData = preload("res://scenes/game/entities/client/client_data.gd").new()
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")

func _ready() -> void:
	print("[MAIN] _ready")
	popup_message.new_client_accepted.connect(handle_accepted_client)
	popup_message.new_client_refused.connect(handle_refused_client)
	popup_message.popup_closed.connect(handle_closing_popup)
	game_information.end_of_the_day.connect(handle_end_of_the_day)
	Global.game_over.connect(handle_game_over)
	add_child(client_data)
	for client_info in Global.game_state.clients:
		print("adding client")
		add_new_client(client_info)
	get_tree().paused = false

func new_email_from_client() -> void:
	print("[MAIN] new_email_from_client")
	var client_info = client_data.get_random_client()
	get_tree().paused = true
	popup_message.show_popup(client_info)

func add_new_client(client_info: Dictionary) -> void:
	print("[MAIN] add_new_client")
	var client: Client = client_scene.instantiate()
	var screen = get_visible_screen()
	var client_position = Vector2(randi_range(500, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position, client_info)
	add_child(client)

func get_visible_screen() -> Vector2:
	print("[MAIN] get_visible_screen")
	return get_viewport().get_visible_rect().size

func handle_accepted_client(client_info: Dictionary) -> void:
	print("[MAIN] handle_accepted_client")
	Global.update_reputation.emit(1)
	Global.new_client_accepted.emit(client_info)
	add_new_client(client_info)
	handle_closing_popup()

func handle_refused_client() -> void:
	print("[MAIN] handle_refused_client")
	handle_closing_popup()

func handle_closing_popup() -> void:
	print("[MAIN] handle_closing_popup")
	$EventSpawner.start(Global.game_config.seconds_between_events)
	$PopupMessage.hide()
	get_tree().paused = false

func handle_end_of_the_day() -> void:
	print("[MAIN] handle_end_of_the_day")
	get_tree().paused = true
	SceneTransition.fade_to_new_day()

func handle_game_over() -> void:
	print("[MAIN] handle_game_over")
	SceneTransition.fade_to_end()
