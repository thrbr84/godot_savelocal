extends Node2D

var rot
var vel
var maxlife
var life
var pointValue = 1
var isDied = false
var sizeScreen

signal point(qtd)

func _ready():
	randomize()
	var dir = [-1,1]
	sizeScreen = get_viewport_rect().size
	
	position.x = rand_range(100, sizeScreen.x-100)
	scale = Vector2(1,1) * (randf() + 1.0)
	
	pointValue = (randi() % 50) + 1
	maxlife = 10
	life = maxlife
	
	rot = (randf() * .01) * dir[randi()%dir.size()]
	
	var levelVel = clamp((1.0 + Game.save_data['level'] / 10), 0.0, 2.0)
	vel = (randi() % 3) + 2 * levelVel
	

func _physics_process(_delta):
	position.y += vel
	rotation += rot
	
	if position.y > sizeScreen.y and !isDied:
		emit_signal("point", -pointValue)
		queue_free()

func _on_area_area_entered(area):
	if isDied: return
	
	if area.is_in_group("laser"):
		var body = area.get_parent()
		body._kill()
		_hit()
		
func _hit():
	if isDied: return
	
	var per = ((life * 100.0 / maxlife)) / 100.0
	$image.modulate.g = 1.0 * per
	$image.modulate.b = 1.0 * per
	
	life -= 10
	if life < 0 and !isDied:
		isDied = true
		emit_signal("point", pointValue)
		$sfxExplosion.play()
		$image.modulate.g = 0
		$image.modulate.b = 0
		while stepify($image.modulate.a, .1) > 0:
			visible = bool(int(stepify($image.modulate.a, .1) * 10) % 2)
			$explosion.visible = bool(int(stepify($image.modulate.a, .1) * 10) % 2)
			$explosion.modulate.a -= .1
			$image.modulate.a -= .1
			yield(get_tree().create_timer(.1), "timeout")
			
		yield($sfxExplosion, "finished")
		queue_free()
		return

	$sfxHit.play()
	var idx = 0
	while idx < 5:
		visible = bool(idx % 2)
		idx += 1
		yield(get_tree().create_timer(.02), "timeout")
	visible = true
