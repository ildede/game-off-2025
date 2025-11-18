extends Node2D

@export var letters: PackedScene

var tasks: Array

func _on_timer_timeout() -> void:
	if tasks.size() != 0:
		fire()

func new_task_arrived(item: PathFollow2D) -> void:
	tasks.append(item)

func fire() -> void:
	print("Task in lista: {0}, scrivo!".format([tasks.size()]))
	var l = letters.instantiate()
	l.position = $Translator.position
	l.target = tasks[0]
	l.task_colpito.connect(task_colpito)
	add_child(l)

func task_colpito(task) -> void:
	print("Il task colpito: ", task)
	print(task.task_id)
	var found = tasks.find_custom(func has_task_id(t):
		return t.get_node("CharacterBody2D").task_id == task.task_id)
	if found >= 0:
		var preso = tasks.pop_at(found)
		preso.queue_free()
