extends Node2D

var rot: float
var vel: float
var maxlife: float
var life: float
var pointValue: int = 1
var isDead:bool = false
var sizeScreen:Vector2 = Vector2.ZERO
var randomRock = RandomNumberGenerator.new()

signal point(qtd) # sinal de quando pontua

func _ready() -> void:
	randomRock.randomize()
	
	var randiNum = randomRock.randi()
	var randfNum = randomRock.randf()
	
	var dir = [-1,1] # direção de rotação
	sizeScreen = get_viewport_rect().size # tamanho da tela
	
	# posição aleatória para a rocha
	position.x = randomRock.randf_range(100, sizeScreen.x-100)
	
	# scala aleatória para a rocha
	scale = Vector2(1,1) * (randfNum + 1.0)
	
	# define um ponto aleatório para essa rocha
	pointValue = (randiNum % 50) + 1
	
	# define a vida aleatória dessa rocha
	maxlife = (randiNum % 50)
	life = maxlife
	
	# define aleatoriamente para que lado vai girar a rocha
	rot = (randfNum * .01) * dir[randiNum % dir.size()]
	
	# define aleatóriamente a velocidade da rocha
	var levelVel = clamp((1.0 + Game.readData('level', 1) / 10), 0.0, 2.0)
	vel = (randiNum % 3) + 2 * levelVel

func _physics_process(_delta):
	position.y += vel # faz a rocha movimentar em Y positivo (para baixo)
	rotation += rot # faz a rocha rotacionar
	
func _on_area_area_entered(area):
	if isDead: return # se a rocha não morreu
	
	# se a rocha saiu da tela e encostou na area
	if area.is_in_group("offScreen") and !isDead:
		emit_signal("point", -pointValue) # retira os pontos
		queue_free()
		return
	
	# Se o laser encostou na rocha
	if area.is_in_group("laser"):
		var body = area.get_parent()
		body._kill() # retira o laser
		_hit() # aplica um hit na rocha
		
func _hit():
	if isDead: return # se a rocha ainda não morreu
	
	# se a vida da rocha ainda é maior que 0
	if life > 0:
		# aplica um efeito para ela ir ficando vermelha conforme vai morrendo
		var per = ((life * 100.0 / maxlife)) / 100.0
		$image.modulate.g = 1.0 * per
		$image.modulate.b = 1.0 * per
		life -= 10
	
	# Se a vida da rocha chegou no 0 e ainda não estava morta
	if life <= 0 and !isDead:
		isDead = true
		emit_signal("point", pointValue) # emite um sinal de ponto
		$sfxExplosion.play() # barulho de explosão
		
		# deixamos o sprite VERMLEHO
		$image.modulate.g = 0 # retiramos a cor VERDE
		$image.modulate.b = 0 # retiramos a cor AZUL
		
		# aqui vamos piscar e deixar a rocha invisivel aos poucos
		# Se a transparência da rocha ainda for maior que 0
		while stepify($image.modulate.a, .1) > 0:
			visible = bool(int(stepify($image.modulate.a, .1) * 10) % 2)
			$explosion.visible = bool(int(stepify($image.modulate.a, .1) * 10) % 2)
			$explosion.modulate.a -= .1
			$image.modulate.a -= .1
			yield(get_tree().create_timer(.1), "timeout")
		
		# Se o audio de explosão ainda está tocando, aguardamos
		if $sfxExplosion.is_playing():
			yield($sfxExplosion, "finished")
		queue_free() # retira a rocha da memória
		return

	# O código abaixo vai ser executado em caso de HIT
	$sfxHit.play() # toca o som de hit
	var idx = 0
	while idx < 5: # faz piscar 5 vezes
		visible = bool(idx % 2)
		idx += 1
		yield(get_tree().create_timer(.02), "timeout")
	visible = true # força a visibilidade para true
