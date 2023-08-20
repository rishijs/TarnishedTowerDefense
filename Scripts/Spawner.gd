extends Sprite2D

var enemy_base = preload("res://Prefabs/enemy_base.tscn")
var enemy_fortified = preload("res://Prefabs/enemy_fortified.tscn")
var enemy_last_breath = preload("res://Prefabs/enemy_last_breath.tscn")
var enemy_overlord = preload("res://Prefabs/enemy_overlord.tscn")

var enemies_spawned = 0
var last_breath_spawned = false

var ready_spawner = true

var level = 1
var wave = -1

#(type,delay till spawn,number of enemies,enemy power)
var tutorial_enemy_types = [[[0,1,1,1]],

						[[0,1,10,1],[0,3,10,2],[0,3,10,3]],
						
						[[0,1,15,4],[0,3,15,5]],
						
						[[0,1,25,5],[0,3,35,4],[0,3,50,3],[0,5,75,2],[0,5,100,1],[0,5,25,5]],
						
						[[1,1,3,1]],
						
						[[0,1,10,5],[1,5,10,2]],
						
						[[1,1,100,3]],
						
						[[0,1,50,5],[0,3,50,4],[0,5,50,5],[1,5,25,5]],
						
						[[0,1,100,4],[0,3,20,5],[1,5,50,3],[1,5,25,4],[1,5,50,5],[0,5,25,5]],
						
						[[0,1,100,5],[1,3,50,5]],
						
						[[3,1,1,100]],
						
						[[3,1,3,100],[0,3,100,5],[1,5,50,5],[0,5,100,5],[1,5,50,5]],
						
						[[0,1,200,5],[1,3,100,5],[3,5,10,100]]
						]

var last_breath_enemy_types = [[2,0,100,3]]

func _ready():
	pass

func _process(delta):
	if ready_spawner == true:
		if wave == 12:
			get_tree().change_scene_to_file("res://Scenes/victory.tscn")
		if wave < tutorial_enemy_types.size()-1:
			wave += 1
			initialize_wave_enemies(0)
			ready_spawner = false
			get_tree().get_nodes_in_group("Bastion")[0].wave_in_progress = true
		
	if get_tree().get_nodes_in_group("Bastion")[0].last_breath == true && last_breath_spawned == false:
		instantiate_enemy_group("LastBreath","last_breath",120,3,0)
		last_breath_spawned = true
		get_tree().get_nodes_in_group("Interface")[0].send_tutorial_cards(get_tree().get_nodes_in_group("Interface")[0].tutorial_cards.size()-1)
	
func initialize_wave_enemies(enemy_index):
	if get_tree().paused == true:
		await get_tree().create_timer(1,false).timeout
		initialize_wave_enemies(enemy_index)
	else:
		match level:
			1:
				if enemy_index < tutorial_enemy_types[wave].size():
					var enemy = tutorial_enemy_types[wave][enemy_index]
					await get_tree().create_timer(enemy[1],false).timeout
					match enemy[0]:
						0:
							instantiate_enemy_group("Path","base",enemy[2],enemy[3],0)
						1:
							instantiate_enemy_group("Path","fortified",enemy[2],enemy[3],0)
						3:
							instantiate_enemy_group("Path","overlord",enemy[2],enemy[3],0)
					initialize_wave_enemies(enemy_index+1)

		
func instantiate_enemy_group(path_name, group_name, group_size, power, position_in_path):
	if get_tree().paused == true:
		await get_tree().create_timer(1,false).timeout
		instantiate_enemy_group(path_name, group_name, group_size, power, position_in_path)
	else:
		for x in range(0,group_size):
			var enemy_curr 
			match group_name:
				"base":
					enemy_curr = enemy_base.instantiate()
					enemy_curr.type = 0
				"fortified":
					enemy_curr = enemy_fortified.instantiate()
					enemy_curr.type = 1
				"last_breath":
					enemy_curr = enemy_last_breath.instantiate()
					enemy_curr.type = 2
				"overlord":
					enemy_curr = enemy_overlord.instantiate()
					enemy_curr.type = 3
					
			enemy_curr.add_to_group(group_name)
			enemy_curr.visible = true
			enemy_curr.starting_pos = -x
			enemy_curr.power = power
			enemy_curr.progress = position_in_path
			get_tree().get_nodes_in_group(path_name)[0].add_child(enemy_curr)
			enemies_spawned += 1
