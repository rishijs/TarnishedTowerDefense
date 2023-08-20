extends RigidBody2D

var type = 3
var fly_time = 1
var burn_tick_time = 2

var root_tower

var corrupted = false

var rebound = false

func _ready():
	if corrupted == true:
		burn_tick_time = 1
		fly_time *= 0.5
	firing_pattern()

func _process(delta):
	if rebound == true:
		rebound = false

func firing_pattern():
	if corrupted == false:
		await get_tree().create_timer(fly_time,false).timeout
		queue_free()
	else:
		linear_velocity *= 1.5
		await get_tree().create_timer(fly_time,false).timeout
		queue_free()
