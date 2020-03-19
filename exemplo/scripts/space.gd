extends Node2D

class_name SpaceNode2D

onready var audioStreamTheme = AudioStreamPlayer.new()
onready var analogController = $UI/AnalogController
onready var player = $UI/plane
onready var camera = $UI/plane/camera
onready var laserScene = preload("res://scenes/laser.tscn")
onready var rocksScene = preload("res://scenes/rocks.tscn")
onready var speed: int = speedInitial

export(int) var points: int = 0
export(int) var level: int = 1
export(int) var highScore: int = 0
export(int) var autoPause: int = 5

var randMusic = RandomNumberGenerator.new()
var speedInitialSpawner: int = 3
var speedInitial: int = 5
var sizePlayer: float
var sizeScreen: float
var levelIncrease: int = 0
var velocity: Vector2 = Vector2.ZERO
var timer = Timer.new()
var idleTimer = Timer.new()

"""
ANALOG CONTROLLER -------------------------
https://github.com/thiagobruno/godot_analogcontroller
"""

func _on_AnalogController_analogChange(force, pos) -> void:
	if get_tree().paused:
		get_tree().paused = false
		
	if timer.is_stopped():
		timer.start()
		
	idleTimer.stop()
	$UI/statusPause.text = str("")
	velocity = (force * 20) # controla a nave

func _on_AnalogController_analogRelease() -> void:
	velocity = Vector2.ZERO # ao soltar o controle
	
	idleTimer.start()

"""
SHOOTER GAME -------------------------
"""

func _ready() -> void:
	sizePlayer = player.texture.get_size().x * player.scale.x / 2
	sizeScreen = get_viewport_rect().size.x
	
	add_child(audioStreamTheme)
	$UI/statusPause.text = str("Control\nto start")
	
	# criamos um timer que irá controlar o spawn das rochas
	timer.wait_time = speedInitialSpawner # ele inicia em speedInitialSpawner segundos porém isso muda conforme o adjustLevelTimer()
	timer.one_shot = false
	timer.autostart = false
	timer.stop()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
	# criamos um timer para controlar o idleTimer
	if autoPause > 0:
		idleTimer.wait_time = autoPause
		idleTimer.one_shot = true
		idleTimer.autostart = false
		idleTimer.connect("timeout", self, "_on_idleTimer_timeout")
		add_child(idleTimer)
	
	# Antes de começar o jogo, colocamos um pequeno delay para dar tempo de carregar nosso save
	yield(get_tree().create_timer(.1), "timeout")
	
	# toca uma nova musica aleatória
	_sortPlayMusic()
	
	# ajustamos a velocidade do jogo conforme o level
	_adjustLevelTimer()
	
func _physics_process(_delta) -> void:
	if weakref(player).get_ref():
		var vel = player.position.x + velocity.x
		player.position.x = clamp(vel, sizePlayer, sizeScreen-sizePlayer)

	var levelVel = clamp((1.0 + level / 10), 0.0, 2.0)
	camera.position.y -= speed * levelVel
	
	if !idleTimer.is_stopped():
		$UI/statusPause.text = str("pause in\n", stepify(idleTimer.time_left, 1),"s")
	
func _shoot() -> void:
	# Se a instancia do player existe
	if weakref(player).get_ref():
		# se o player é um plane
		if player.is_in_group("plane"):
			# instancia um laser
			var laser = laserScene.instance()
			laser.position = player.get_node("shoot").position
			laser.z_index = -1
			player.add_child(laser)
			# define o laser como toplevel para não ficar dentro do player
			laser.set_as_toplevel(true)

func _input(event) -> void:
	# Se apertar o espaço pelo teclado vai atirar
	if event.is_action_pressed("ui_accept"):
		_shoot()
	
	if event is InputEventScreenTouch:
		if event.is_pressed() and (event.position.y > 300 and event.position.y < 1280-200):
			_shoot()

func _on_timer_timeout() -> void:
	# instancia novas rochas
	var rock = rocksScene.instance()
	rock.global_position = Vector2.ZERO
	rock.z_index = -1
	rock.connect("point", self, "_on_point")
	$UI.add_child(rock)
	rock.set_as_toplevel(true)

func _newGame() -> void:
	# reseta as variáveis do jogo
	speed = speedInitial
	timer.wait_time = speedInitialSpawner
	# remove todas as rochas
	for r in get_tree().get_nodes_in_group("rock"):
		r.queue_free()
	# toca uma nova musica aleatória
	_sortPlayMusic()
	
func _adjustLevelTimer() -> void:
	var newTime = clamp((timer.wait_time - level / 100.0), 1.00, 5.00)
	timer.wait_time = newTime

func _sortPlayMusic() -> void:
	# randomiza uma musica de 1 à 4 conforme os arquivos que temos no diretório
	randMusic.randomize()
	
	var option = (randMusic.randi() % 4) + 1
	var fileStream = load(str("res://assets/audio/theme/",option,".ogg"))
	audioStreamTheme.stream = fileStream
	audioStreamTheme.volume_db = -10
	audioStreamTheme.play()

func _on_idleTimer_timeout():
	if !get_tree().paused:
		get_tree().paused = true
		$UI/statusPause.text = str("paused")
		idleTimer.stop()
