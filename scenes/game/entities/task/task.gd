extends PathFollow2D
class_name Task

var total_time = Config.DAY_LENGHT_IN_SECONDS
var running_time = 0
var remaining_words = 1

func _ready() -> void:
	set_progress_ratio(lerp(0, 1, running_time / total_time))
	$Target.play("default")
	Global.new_priority_task.connect(handle_priority_task)

func handle_priority_task(task: Task) -> void:
	$Target.visible = get_task_id() == task.get_task_id()

func _physics_process(delta: float) -> void:
	running_time += delta
	set_progress_ratio(lerp(0, 1, running_time / total_time))
	rotation = 0

func initialize(task_info: Models.OngoingTask):
	get_node("CharacterBody2D").task_id = task_info.task_id
	remaining_words = task_info.remaining_words
	$ProgressBar.max_value = task_info.total_words
	$ProgressBar.value = task_info.total_words - task_info.remaining_words
	$Label.text = str(task_info.remaining_words)
	if task_info.deadline_days == 1:
		total_time = Global.game_clock.time_left
	else:
		total_time = Config.DAY_LENGHT_IN_SECONDS * (task_info.deadline_days)
	
	running_time = Config.DAY_LENGHT_IN_SECONDS * (Global.game_state.current_day - task_info.assigned_on)


func update_progress(letter: Letter) -> bool:
	$ProgressBar.value += letter.word_count
	remaining_words -= letter.word_count
	$Label.text = str(remaining_words)
	if $ProgressBar.max_value == $ProgressBar.value:
		return true
	else:
		return false

func get_task_id() -> int:
	return get_node("CharacterBody2D").task_id


func _on_character_body_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		Global.new_priority_task.emit(self)

func _on_delete_pressed() -> void:
	print("deleted pressed")
	Global.task_deleted.emit(get_task_id())

func _on_character_body_2d_mouse_entered() -> void:
	$Delete.visible = true

func _on_character_body_2d_mouse_exited() -> void:
	$Delete.visible = false
