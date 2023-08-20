extends PathFollow2D

const ratio_increments = 0.0001

var type = 0

var speed
var enemy_separation = -1

var enemy_sprite
var starting_pos

var reached_bastion = false
var damage

var power

var frozen = false
var speed_multiplier = 1
var slow_slider_multiplier = 1
var max_slider_slow = 0.95
var min_slide_slow = 1.5
var hit_lifetime = 0.1

var fortified = false
var overlord = false
var invulnerability = false

var regular_hit = preload("res://Prefabs/regular.tscn")
var critical_hit = preload("res://Prefabs/critical.tscn")

func _ready():
	enemy_sprite = get_child(0).get_child(1)
	match type:
		0:
			invulnerability = true
			status_effect_countdown("invulnerability",1)
		1:
			invulnerability = true
			status_effect_countdown("invulnerability",2)
			fortified = true
		2:
			invulnerability = true
			status_effect_countdown("invulnerability",2.5)
			status_effect_countdown("regen",1)
		3:
			invulnerability = true
			status_effect_countdown("invulnerability",4)
			overlord = true
			
	change_form()
	start_timer()

func _process(delta):
	if get_tree().get_nodes_in_group("Interface")[0].score > 0:
		slow_slider_multiplier = (min_slide_slow- max_slider_slow * get_tree().get_nodes_in_group("SlowSlider")[0].value/get_tree().get_nodes_in_group("SlowSlider")[0].max_value)
	elif get_tree().get_nodes_in_group("Interface")[0].score == 0:
		slow_slider_multiplier = 1
			
	if get_tree().get_nodes_in_group("Bastion")[0].last_breath == true:
		if get_groups()[1] != "last_breath":
			queue_free()
	
	change_form()
	handle_movement()
	damage_the_bastion()

func damage_the_bastion():
	if progress_ratio > 0.99:
		reached_bastion = true
	if reached_bastion == true && get_tree().get_nodes_in_group("Bastion")[0].last_breath == false:
		get_tree().get_nodes_in_group("Bastion")[0].enemies_sacrificed += 1
		if overlord == false:
			get_tree().get_nodes_in_group("Bastion")[0].current_health -= damage
		else:
			get_tree().get_nodes_in_group("Bastion")[0].current_health = 0
		queue_free()

func change_form():
	damage = power
	if frozen == true:
		speed_multiplier = 0
	else:
		speed_multiplier = 1
	
	if overlord == true:
		speed = 3 * speed_multiplier * slow_slider_multiplier
		enemy_separation = 3
		scale.x = maxf(power/100.0,0.3) * 3
		scale.y = maxf(power/100.0,0.3) * 3
		if power <= 0:
			get_tree().get_nodes_in_group("Spawner")[0].instantiate_enemy_group("Path","last_breath",50,5,progress-0.1)
			get_tree().get_nodes_in_group("Bastion")[0].enemies_killed += 1
			queue_free()
	else:	
		match power:
			1:
				enemy_sprite.self_modulate = Color("#eb3b26")
				speed = 5 * speed_multiplier * slow_slider_multiplier
				enemy_separation = 0.125
			2:
				enemy_sprite.self_modulate = Color("#1da2de")
				speed = 6 * speed_multiplier * slow_slider_multiplier
				enemy_separation = 0.15
			3:
				enemy_sprite.self_modulate = Color("#20d475")
				speed = 7.5 * speed_multiplier * slow_slider_multiplier
				enemy_separation = 0.175
			4:
				enemy_sprite.self_modulate = Color("#ffd35c")
				speed = 12.5 * speed_multiplier * slow_slider_multiplier
				enemy_separation = 0.2
			5:
				enemy_sprite.self_modulate = Color("#ffddd4")
				speed = 15 * speed_multiplier * slow_slider_multiplier
				enemy_separation = 0.25
			_:
				if overlord == false:
					get_tree().get_nodes_in_group("Bastion")[0].enemies_killed += 1
					queue_free()
			
func handle_movement():
	if starting_pos == 0:
		progress_ratio += speed * ratio_increments

func start_timer():
	await get_tree().create_timer(enemy_separation,false).timeout
	if starting_pos < 0:
		starting_pos += 1
	start_timer()

func status_effect_countdown(effect,duration):
	await get_tree().create_timer(duration,false).timeout
	match effect:
		"freeze":
			frozen = false
			get_child(2).visible = false
		"burn":
			power -= 1
			status_effect_countdown("burn",duration)
		"regen":
			if power < 3:
				power += 1
			status_effect_countdown("regen",duration)
		"invulnerability":
			invulnerability = false
	
func _on_area_2d_body_entered(body):
	if body.get_groups()[0] == "Projectile" && progress > 0.025 && invulnerability == false:
		
		if overlord == false:
			var hit_effect = regular_hit.instantiate()
			hit_effect.position = position
			get_tree().get_nodes_in_group("Effects")[0].add_child(hit_effect)
		
		if !((fortified == true || overlord == true) && body.corrupted == true):
			power -= 1
			get_tree().get_nodes_in_group("Bastion")[0].currency += 1
			get_tree().get_nodes_in_group("Interface")[0].score += 1*get_tree().get_nodes_in_group("Interface")[0].elim_points
			if get_tree().get_nodes_in_group("Bastion")[0].last_breath == true:
				get_tree().get_nodes_in_group("Bastion")[0].current_health += 0.175
			body.root_tower.curr_resistance -=  body.root_tower.tower_stats.absorption/body.root_tower.tower_stats.protection * (body.root_tower.tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
			
			if body.type == 1:
				frozen = true
				get_child(2).visible = true
				status_effect_countdown("freeze",body.freeze_duration+randf_range(0,body.freeze_duration_rng))
				
			if body.type == 2:
				if randf_range(0,1) < body.critical_chance:
					power -= body.critical_damage
					var critical_hit_effect = critical_hit.instantiate()
					critical_hit_effect.position = position
					get_tree().get_nodes_in_group("Effects")[0].add_child(critical_hit_effect)
				body.queue_free()
				
			if body.type == 3:
				status_effect_countdown("burn",body.burn_tick_time)
				get_child(1).visible = true
				if body.corrupted == false:
					body.queue_free()
