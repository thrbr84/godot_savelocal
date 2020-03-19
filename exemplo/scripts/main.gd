extends SpaceNode2D

func _ready():
	level = Game.readData('level', 1)
	points = Game.readData('points')
	highScore = Game.readData('highScore')
	
	Game.connect("onSave", self, "_on_saveFile")
	_updateLabels()
	
func _updateLabels():
	$UI/levelNum.text = str(level)
	$UI/pointsNum.text = str(points)
	$UI/pointsAccumulatedNum.text = str(highScore)

func _on_point(qtd):
	points += qtd
	levelIncrease += qtd 
	
	if sign(qtd) > 0: # se estiver somando
		# Posso enviar um campo que incrementa com um valor antigo
		if points > highScore:
			highScore = points
			Game.saveData({
				"highScore": points
			}) # se não informarmos o "increment" esses valores serão sobrescritos
			
			# Aqui apenas incrementa os pontos do jogador
			Game.saveData({
				"totalAcumulado": qtd,
			}, "increment") # informando esse parametro incrementa o valor com o que está salvo
	
	if points < 0:
		points = 0
		
	if levelIncrease >= 100: # a cada 100 pontos
		levelIncrease = 0
		level+= 1 # incrementa o level
		_adjustLevelTimer() # ajusta a velocidade do jogo

	# Trabalha com variável local
	_updateLabels()
	# Salvo os dados que eu quero, posso enviar um ou outro
	Game.saveData({
		"level": level,
		"points": points
	})

func _on_btnResetGame_pressed():
	$sfxSelect1.play()
	
	Game.deleteFileSave()
	_newGame()
	level = 1
	points = 0
	highScore = 0
	_adjustLevelTimer()
	_updateLabels()

func _on_btnResetPoints_pressed():
	$sfxSelect2.play()
	points = 0
	Game.saveData({
		"points": points
	})
	Game.onlySaveData()
	_updateLabels()

func _on_timerSave_timeout():
	Game.onlySaveData()

func _on_saveFile(_data):
	var idx = 0
	while idx < 5:
		$UI/bkg/icon.modulate.a = .5 if bool(idx % 2) else 1
		yield(get_tree().create_timer(.1), "timeout")
		idx += 1
	$UI/bkg/icon.modulate.a = 1
