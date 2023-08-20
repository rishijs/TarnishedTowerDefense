extends "res://Scripts/Tower.gd"

var projectile2 = preload("res://Prefabs/tower_2_projectile.tscn")

var tower2_stats = {
	tower_type = 2,
	fire_rate = 0.5,
	lock_on_rate = 0.1,
	projectiles = 5,
	resistance = 100,
	strain = 0.01,
	exertion = 0.1,
	absorption = 1.5,
	failure_dmg = 10,
	time_till_destruction = 5,
	protection = 2.0,
	projectile_speed_max = 200,
	projectile_speed_angular_min = 700,
	projectile_speed_angular_max = 1000,
}

var direction = 0

func _ready():
	initialize_tower_dictionary(tower2_stats)
	super()

func _process(delta):
	if direction == 4:
		direction = 0
	super(delta)

func initialize_tower_dictionary(new_tower_stats):
	super(new_tower_stats)

func create_projectile(num_projectiles):
	
	for x in range(0,num_projectiles):
		var curr_projectile = projectile2.instantiate()
		
		curr_projectile.root_tower = self
		curr_projectile.linear_velocity = calculate_projectile_speed(x)
		curr_projectile.angular_velocity = randi_range(tower_stats.projectile_speed_angular_min, tower_stats.projectile_speed_angular_max)
		match direction:
			0:
				curr_projectile.position = get_child(5).position
			1:
				curr_projectile.position = get_child(6).position
			2:
				curr_projectile.position = get_child(7).position
			3:
				curr_projectile.position = get_child(8).position
			
		if corrupted == true:
			curr_projectile.corrupted = true
		add_child(curr_projectile)

func calculate_projectile_speed(projectile_index):
	match direction:
		0:
			return Vector2(0,-tower_stats.projectile_speed_max)
		1:
			return Vector2(-tower_stats.projectile_speed_max,0)
		2:
			return Vector2(0,tower_stats.projectile_speed_max)
		3:
			return Vector2(tower_stats.projectile_speed_max,0)

func fire_projectiles(num_projectiles):
	if enemy_in_range == true || corrupted == true:
		if first_shot == true:
			create_projectile(num_projectiles)
			direction +=1
			curr_resistance -= tower_stats.exertion * (tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
			first_shot = false
			
		elif first_shot == false:
			await get_tree().create_timer(fire_rate,false).timeout
			curr_resistance -= tower_stats.exertion * (tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
			create_projectile(num_projectiles)
			direction += 1
			
		fire_projectiles(num_projectiles)
		
	elif enemy_in_range == false:
		await get_tree().create_timer(tower_stats.lock_on_rate,false).timeout
		fire_projectiles(num_projectiles)

func corruption_overload(time_left):
	get_child(3).visible = false
	get_child(4).visible = true
	get_child(4).text = str(time_left)
	if time_left < 3:
		get_child(4).modulate = Color(255,0,0,1)
	await get_tree().create_timer(1,false).timeout
	if corrupted == true:
		if time_left == 0:
			get_child(4).text = str(time_left)
			get_tree().get_nodes_in_group("Interface")[0].place_locations[placed_location] = false
			if get_tree().get_nodes_in_group("Bastion")[0].last_breath == false:
				get_tree().get_nodes_in_group("Bastion")[0].current_health -= tower_stats.failure_dmg
			queue_free()
		fire_rate = 0.025
		corruption_overload(time_left-1)
