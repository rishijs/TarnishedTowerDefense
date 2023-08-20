extends Node

@export var disabled = false

var tower_stats = {
	tower_type = 1,
	fire_rate = 3,
	lock_on_rate = 0.1,
	projectiles = 2,
	resistance = 100,
	strain = 0.04,
	exertion = 8,
	absorption = 0.1,
	failure_dmg = 20,
	time_till_destruction = 10,
	protection = 1.4,
	projectile_speed_min = 100,
	projectile_speed_max = 200
}

var placed_location = -1

var fire_rate
var projectiles

var enemy_in_range = false
var enemies_in_range = 0
var first_shot = true

var curr_resistance
var corrupted = false
var transformed = false

var projectile = null

func _ready():
	fire_rate = tower_stats.fire_rate
	projectiles = tower_stats.projectiles
	curr_resistance = tower_stats.resistance
	get_child(3).max_value = tower_stats.resistance
	get_child(3).value = curr_resistance
	if disabled == false:
		fire_projectiles(tower_stats.projectiles)


func _process(delta):
	curr_resistance -= tower_stats.strain * (tower_stats.protection-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
	if curr_resistance <= 0:
		corrupted = true
		curr_resistance = 0
	get_child(3).value = curr_resistance
	if corrupted == true && transformed == false:
		get_child(0).get_child(0).visible = true
		get_child(0).get_child(1).playing = true
		corruption_overload(tower_stats.time_till_destruction)
		transformed = true
	elif corrupted == false:
		get_child(0).get_child(0).visible = false
		
func initialize_tower_dictionary(new_tower_stats):
	tower_stats = new_tower_stats
	
func corruption_overload(time_left):
	#corruption actions
	time_left = 0
	
func fire_projectiles(num_projectiles):
	#establish firing pattern
	num_projectiles = 0

func create_projectile(num_projectiles):
	#create projectiles and assign them
	for x in range(0,num_projectiles):
		var curr_projectile = null
	
func calculate_projectile_speed(projectile_index):
	#match statement for what speed to give each projectile
	match projectile_index:
		_:
			return Vector2(0,0)


func _on_area_2d_area_entered(area):
	if area.get_node("../").get_groups().size() > 0:
		if area.get_node("../").get_groups()[0] == "enemy":
			enemies_in_range += 1
			enemy_in_range = true


func _on_area_2d_area_exited(area):
	if area.get_node("../").get_groups().size() > 0:
		if area.get_node("../").get_groups()[0] == "enemy":
			enemies_in_range -= 1
			if enemies_in_range == 0:
				enemy_in_range = false
			
