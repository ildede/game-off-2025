extends Node

var clients_data: Array

func _ready() -> void:
	load_clients_data()

func load_clients_data():
	var file = FileAccess.open("res://data/clients.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var data = json.get_data()
			clients_data = data["clients"]
		else:
			push_error("JSON Parse Error: ", json.get_error_message())
	else:
		push_error("Failed to load clients.json")

func get_random_client() -> Dictionary:
	return create_fallback_client()
	#if clients_data.is_empty():
		#return create_fallback_client()
#
	#return clients_data[randi() % clients_data.size()]

func create_fallback_client() -> Dictionary:
	return {
		"id": "client_2",
		"name": "TechManual Inc.",
		"engagement_email": "Looking for a translator to handle 300 words daily of technical documentation. This is an ongoing daily requirement. By the end of the day after the assignment you should have finished",
		"deadline_in_days": 0,
		"daily_words": 300,
		"payment_per_word": 0.04
	}
