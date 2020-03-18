extends Node2D

var speed = 50

func _physics_process(_delta):
	# incrementa em Y negativo, fazendo o laser subir
	global_position.y -= speed

func _kill():
	# retira a imagem
	if weakref($image).get_ref():
		$image.queue_free()
	# retira a area
	if weakref($area).get_ref():
		$area.queue_free()
	# Se o som estiver tocando, aguarda terminar
	if $sfx.is_playing():
		yield($sfx,"finished")
	queue_free()

func _on_area_area_entered(area):
	# Se o laser encostou na area fora da tela
	if area.is_in_group("offScreen"):
		_kill()
