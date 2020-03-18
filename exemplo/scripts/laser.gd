extends Node2D

func _physics_process(_delta):
	global_position.y -= 50

func _on_VisibilityNotifier2D_screen_exited():
	_kill()

func _kill():
	if weakref($image).get_ref():
		$image.queue_free()
	if weakref($area).get_ref():
		$area.queue_free()
	yield($sfx,"finished")
	queue_free()
