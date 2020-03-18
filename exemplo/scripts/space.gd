extends Node2D

class_name SpaceNode2D

onready var analogController = $UI/AnalogController
onready var player = $UI/plane
onready var camera = $UI/plane/camera
onready var laserScene = preload("res://scenes/laser.tscn")
onready var rocksScene = preload("res://scenes/rocks.tscn")

var speed = 5
export var points = 0
export var level = 1
var sizePlayer
var sizeScreen
var levelIncrease = 0
var velocity = Vector2.ZERO
var timer = Timer.new()

"""
ANALOG CONTROLLER -------------------------
"""

func _on_AnalogController_analogChange(force, pos):
	velocity = (force * 20)

func _on_AnalogController_analogRelease():
	velocity = Vector2.ZERO

"""
SHOOTER GAME -------------------------
"""

func _ready():
	sizePlayer = player.texture.get_size().x * player.scale.x / 2
	sizeScreen = get_viewport_rect().size.x
	
	timer.wait_time = 3
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	
func _physics_process(_delta):
	if weakref(player).get_ref():
		var vel = player.position.x + velocity.x
		player.position.x = clamp(vel, sizePlayer, sizeScreen-sizePlayer)

	var levelVel = clamp((1.0 + Game.save_data['level'] / 10), 0.0, 2.0)
	camera.position.y -= 5 * levelVel
	
func _shoot():
	if weakref(player).get_ref():
		if player.is_in_group("plane"):
			var laser = laserScene.instance()
			laser.position = player.get_node("shoot").position
			laser.z_index = -1
			player.add_child(laser)
			laser.set_as_toplevel(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_shoot()
		
	if event is InputEventScreenTouch:
		if event.is_pressed() and (event.position.y > 300 and event.position.y < 1280-200):
			_shoot()

func _on_timer_timeout():
	var rock = rocksScene.instance()
	rock.global_position = Vector2.ZERO
	rock.z_index = -1
	rock.connect("point", self, "_on_point")
	$UI.add_child(rock)
	rock.set_as_toplevel(true)
