extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(path: String):
	# تأجيل التغيير حتى تنتهي الإطارات البرمجية الحالية
	call_deferred("_deferred_change_scene", path)

func _deferred_change_scene(path: String):
	current_scene.free()
	var new_scene = load(path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
