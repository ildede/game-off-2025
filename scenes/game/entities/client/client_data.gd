extends Node
class_name ClientData

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
	if clients_data.is_empty():
		return create_fallback_client()

	return clients_data[randi() % clients_data.size()]

func create_fallback_client() -> Dictionary:
	return {
		"name": "Cliente Default",
		"task_interval": 4.0,
		"payment": 60,
		"engagement_email": "Traduzione necessaria."
	}
