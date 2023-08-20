extends RigidBody2D

var type = 2
var fly_time = 10
var critical_chance = 0.05
var critical_damage = 3

var root_tower

var corrupted = false

var rebound = false

func _ready():
	if corrupted == true:
		fly_time *= 1.5
	firing_pattern()

func _process(delta):
	if rebound == true:
		rebound = false

func firing_pattern():
	if corrupted == false:
		await get_tree().create_timer(fly_time,false).timeout
		queue_free()
	else:
		linear_velocity *= 2.5
		await get_tree().create_timer(fly_time,false).timeout
		queue_free()
