extends Node2D
class_name Translator

@export var letters: PackedScene

var tasks: Array

func _ready() -> void:
	Global.client_send_task.connect(new_task_arrived)
	Global.letter_hit_task.connect(task_hit)

func _on_timer_timeout() -> void:
	if tasks.size() != 0:
		fire()

func new_task_arrived(item: PathFollow2D) -> void:
	tasks.append(item)

func fire() -> void:
	var l = letters.instantiate()
	l.position = $Translator.position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	var target_task = tasks.pick_random()
	l.target = target_task
	l.target_id = target_task.get_node("CharacterBody2D").task_id
	add_child(l)

func task_hit(letter, task) -> void:
	Global.update_reputation.emit(0.2)
	Global.update_stress.emit(-0.5)

	var found_index = tasks.find_custom(func has_task_id(t):
		return t.get_node("CharacterBody2D").task_id == task.task_id)
	if found_index >= 0:
		var is_finished = tasks[found_index].update_progress()
		if is_finished:
			var task_found = tasks.pop_at(found_index)
			Global.update_money.emit(task_found.money_value)
			task_found.queue_free()
		letter.queue_free()

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if "task_id" in body:
		Global.update_reputation.emit(-0.5)
		Global.update_stress.emit(2)
		var found_index = tasks.find_custom(func has_task_id(t):
			return t.get_node("CharacterBody2D").task_id == body.task_id)
		if found_index >= 0:
			var task_found = tasks.pop_at(found_index)
			task_found.queue_free()
	
