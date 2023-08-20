extends "res://Scripts/Tower.gd"

var projectile1 = preload("res://Prefabs/tower_1_projectile.tscn")

var tower1_stats = {
	tower_type = 1,
	fire_rate = 3,
	lock_on_rate = 0.1,
	projectiles = 2,
	resistance = 100,
	strain = 0.02,
	exertion = 10,
	absorption = 0.01,
	failure_dmg = 10,
	time_till_destruction = 10,
	protection = 1.6,
	projectile_speed_min = 100,
	projectile_speed_max = 200
}

func _ready():
	initialize_tower_dictionary(tower1_stats)
	super()

func _process(delta):
	super(delta)

func initialize_tower_dictionary(new_tower_stats):
	super(new_tower_stats)

func create_projectile(num_projectiles):
	
	for x in range(0,num_projectiles):
		var curr_projectile = projectile1.instantiate()
		
		curr_projectile.root_tower = self
		curr_projectile.linear_velocity = calculate_projectile_speed(x)
		if x%2 == 0:
			curr_projectile.position = get_child(5).position
		if x%2 == 1:
			curr_projectile.position = get_child(6).position
			
		if corrupted == true:
			curr_projectile.corrupted = true
		add_child(curr_projectile)

func calculate_projectile_speed(projectile_index):
	match projectile_index:
		0:
			return Vector2(0,-1*tower_stats.projectile_speed_max)
		1:
			return Vector2(0,tower_stats.projectile_speed_max)
		2:
			return Vector2(-1*tower_stats.projectile_speed_max,-1*tower_stats.projectile_speed_min)
		3:
			return Vector2(tower_stats.projectile_speed_max,tower_stats.projectile_speed_min)
		_:
			return Vector2(0,0)

func fire_projectiles(num_projectiles):
	if corrupted == true:
		num_projectiles = projectiles * 2
	elif corrupted == false:
		num_projectiles = tower_stats.projectiles
	if enemy_in_range == true || corrupted == true:
		if first_shot == true:
			create_projectile(num_projectiles)
			curr_resistance -= tower_stats.exertion * (tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
			first_shot = false
			
		elif first_shot == false:
			await get_tree().create_timer(fire_rate,false).timeout
			curr_resistance -= tower_stats.exertion * (tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
			create_projectile(num_projectiles)
			
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
		fire_rate = 1
		corruption_overload(time_left-1)
