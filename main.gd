extends Node2D

@export var client_scene: PackedScene

func _ready() -> void:
	pass

func _on_button_pressed() -> void:
	add_new_client()

func add_new_client() -> void:
	var client = client_scene.instantiate()
	client.translator = $Translator
	var screen = get_visible_screen()
	client.position = Vector2(randi_range(400, screen[0]-100), randi_range(100, screen[1]-100))
	client.new_task.connect($Translator.new_task_arrived)
	add_child(client)

func get_visible_screen() -> Vector2:
	return get_viewport().get_visible_rect().size
