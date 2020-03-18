extends SpaceNode2D

func _ready():
	level = Game.readData('level')
	points = Game.readData('points')
	_updateLabels()

func _updateLabels():
	$UI/levelNum.text = str(level)
	$UI/pointsNum.text = str(points)

func _on_point(qtd):
	points += qtd
	levelIncrease += qtd
	if points < 0:
		points = 0
		
	if levelIncrease >= 100:
		levelIncrease = 0
		level+= 1
		var newTime = clamp((timer.wait_time - level / 10.0), 0.5, 5.0)
		timer.wait_time = newTime

	# Trabalha com variável local
	_updateLabels()
	Game.saveData({
		"level": level,
		"points": points
	})
	
func _on_btnResetGame_pressed():
	level = 1
	points = 0
	Game.saveData({
		"level": level,
		"points": points
	})
	Game.onlySaveData()
	_updateLabels()

func _on_timerSave_timeout():
	Game.onlySaveData()
