extends RigidBody2D

var type = 1
var fly_time_forward = 1
var fly_time_back = 1.2
var freeze_duration = 0.55
var freeze_duration_rng = 0.20

var root_tower

var corrupted = false

var rebound = false

func _ready():
	if corrupted == true:
		fly_time_forward *= 4
		fly_time_back *= 0
		freeze_duration_rng *= 10
	firing_pattern()

func _process(delta):
	if rebound == true:
		linear_velocity.x *= -1
		linear_velocity.y *= -1
		rebound = false

func firing_pattern():
	if corrupted == false:
		await get_tree().create_timer(fly_time_forward,false).timeout
		linear_velocity.x *= -1
		linear_velocity.y *= -1
		await get_tree().create_timer(fly_time_back,false).timeout
		queue_free()
	else:
		linear_velocity.y *= 1.5
		await get_tree().create_timer(fly_time_forward,false).timeout
		queue_free()
