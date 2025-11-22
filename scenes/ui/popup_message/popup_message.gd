extends Window
class_name PopupMessage

signal new_client_accepted
signal new_client_refused

var last_client_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("popup_message ready")
	pass # Replace with function body.

func show_popup(client_data: Dictionary) -> void:
	last_client_data = client_data
	$GridContainer/ClientName.text = client_data.get("name", "Client")
	$GridContainer/Interval.text = "%d daily words" % client_data.get("daily_words", 1)
	$GridContainer/Payment.text = "Will pay %.2f $ per word" % client_data.get("payment_per_word", 0.01)
	$GridContainer/RichTextLabel.text = client_data.get("engagement_email", "Email body")
	popup_centered()

func _on_accept_pressed() -> void:
	new_client_accepted.emit(last_client_data)

func _on_refuse_pressed() -> void:
	new_client_refused.emit()
