extends Node2D

const client_scene = preload("res://client/client.tscn")

func _ready() -> void:
	pass

func _on_button_pressed() -> void:
	add_new_client()

func add_new_client() -> void:
	var client = client_scene.instantiate()
	var screen = get_visible_screen()
	var client_position = Vector2(randi_range(500, screen[0]-110), randi_range(140, screen[1]-160))
	var translator_position = $Translator.global_position
	client.initialize(client_position, translator_position)
	add_child(client)

func get_visible_screen() -> Vector2:
	return get_viewport().get_visible_rect().size
