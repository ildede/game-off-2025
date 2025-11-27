extends Node2D
class_name Main

@onready var game_information: GameInformation = $GameInformation
@onready var screen = get_viewport().get_visible_rect().size
@onready var client_scene = preload("res://scenes/game/entities/client/client.tscn")

func _ready() -> void:
	print("[MAIN] _ready")
	Global.set_clock($GameClock)
	Global.game_over.connect(handle_game_over)
	for client_info in Global.game_state.clients:
		add_new_client_to_scene(client_info)
	#$TaskSpawner.start(100)
	if Global.game_state.current_day == 1:
		$EventSpawner.start(0.2)
	else:
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)

	$GameClock.start(Config.DAY_LENGHT_IN_SECONDS)
	$GameClock.timeout.connect(handle_end_of_the_day)

	get_tree().paused = false

func new_email_from_client() -> void:
	print("[MAIN] new_email_from_client")
	var client_info = ClientData.get_random_client()
	get_tree().paused = true
	open_popup_message_for_new_client(client_info)

func _spawn_pending_tasks():
	print("[MAIN] check {0} clients for spawing tasks".format([Global.game_state.clients.size()]))

func add_new_client_to_scene(client_info: Models.ClientObject) -> void:
	print("[MAIN] add_new_client_to_scene")
	var client: ClientScene = client_scene.instantiate()
	
	var client_position = Vector2(randi_range(700, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position, client_info)
	add_child(client)

func handle_end_of_the_day() -> void:
	print("[MAIN] handle_end_of_the_day")
	get_tree().paused = true
	SceneTransition.fade_to_new_day()

func handle_game_over() -> void:
	print("[MAIN] handle_game_over")
	SceneTransition.fade_to_end()

func open_popup_message_for_new_client(client: Models.ClientObject) -> void:
	var popup_data = CustomizablePopupMessage.PopupData.new()
	popup_data.title = "New email"
	var message_lines: Array[String] = [client.engagement_email]
	popup_data.lines = message_lines

	var accept_btn = CustomizablePopupMessage.PopupButton.new()
	accept_btn.text = "Accept"
	accept_btn.action = func():
		Global.new_client_accepted.emit(client)
		add_new_client_to_scene(client)
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		get_tree().paused = false

	var refuse_btn = CustomizablePopupMessage.PopupButton.new()
	refuse_btn.text = "Refuse"
	refuse_btn.action = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		get_tree().paused = false

	var btns: Array[CustomizablePopupMessage.PopupButton] = [accept_btn, refuse_btn]
	popup_data.buttons = btns

	popup_data.on_close = func():
		$EventSpawner.start(Config.SECONDS_BETWEEN_EVENTS)
		get_tree().paused = false

	$CustomPopupMessage.show_popup(popup_data)
