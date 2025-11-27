extends Node2D
class_name Translator

@export var letters: PackedScene

var tasks: Array[Task]

func _ready() -> void:
	#Each fired letter reppresent a certain amount of words
	var max_words_per_day = Config.WORDS_PER_DAY as float / Config.WORDS_PER_LETTER
	$WPM.start(Config.DAY_LENGHT_IN_SECONDS/max_words_per_day)
	Global.client_send_task.connect(new_task_arrived)
	Global.letter_hit_task.connect(task_hit)

func _on_timer_timeout() -> void:
	if tasks.size() != 0:
		$Translator.play("typing")
		fire()
	else:
		$Translator.stop()

func new_task_arrived(item: Task) -> void:
	tasks.append(item)

func fire() -> void:
	var l = letters.instantiate()
	l.position = $Translator.position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	var target_task = tasks.pick_random()
	l.target = target_task
	l.target_id = target_task.get_node("CharacterBody2D").task_id
	add_child(l)

func task_hit(letter: Letter, task: Task) -> void:

	var found_index = tasks.find_custom(func has_task_id(t):
		return t.get_task_id() == task.get_task_id())
	if found_index >= 0:
		var is_finished = tasks[found_index].update_progress(letter)
		if is_finished:
			var task_found = tasks.pop_at(found_index)
			Global.task_finished.emit(task_found.get_task_id())
			task_found.queue_free()
		letter.queue_free()

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if body is TaskBody:
		Global.update_reputation.emit(-1)
		Global.update_stress.emit(4)
