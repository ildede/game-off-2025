extends Window
class_name CustomizablePopupMessage

class PopupData:
	var title: String = ""
	var lines: Array[String] = []
	var buttons: Array[PopupButton] = []
	var on_close: Callable = func():pass

class PopupButton:
	var text: String = ""
	var action: Callable = func():pass

func show_popup(popup_data: PopupData) -> void:
	title = popup_data.title
	$GridContainer/RichTextLabel.text = ""
	$GridContainer/RichTextLabel.bbcode_enabled = true
	for line in popup_data.lines:
		$GridContainer/RichTextLabel.append_text(line)
		$GridContainer/RichTextLabel.newline()

	$GridContainer/GridContainer.columns = popup_data.buttons.size()
	for n in $GridContainer/GridContainer.get_children(): n.queue_free()
	for button in popup_data.buttons:
		var b = Button.new()
		b.text = button.text
		b.pressed.connect(func():_closing_function(button.action))
		$GridContainer/GridContainer.add_child(b)

	close_requested.connect(func():_closing_function(popup_data.on_close))
	popup_centered()

func _closing_function(callable):
	callable.call()
	hide()
