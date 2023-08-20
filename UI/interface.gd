extends CanvasLayer

var tower1 = preload("res://Prefabs/tower_1.tscn")
var tower2 = preload("res://Prefabs/tower_2.tscn")
var tower3 = preload("res://Prefabs/tower_3.tscn")

var max_towers
var place_locations = []

var score = 1000
var passive_points_gain = 1
var elim_points = 10
var score_multiplier = 10

var tower_selected = -1

var muted = false

# message, wave, shown
var tutorial_cards = [["Just a single enemy, click a tower, then select a position to defend the bastion.",0],
					  ["Towers will corrupt over time, either through their attacks, damage, or constant loss.",2],
					  ["Repair the towers before they explode and deal damage to the bastion.",3],
					  ["Fortified enemies only take damage from towers that are functioning properly.",4],
					  ["Use the two sliders on the bottom right to dynamically change the game to your pace.",5],
					  ["Good luck beating wave 13, and any feedback is greaty appreciated.",6],
					  ["The Overlord is a powerful enemy that breaks into smaller regenerating enemies.",10],
					  ["Heal the bastion, back from the dead, by destroying enemies in a short time.",999]]

func _ready():
	initialize_tower_locations()
	send_tutorial_cards(0)

func _process(delta):
	get_tree().get_nodes_in_group("WaveLabel")[0].text = "Wave "+str(get_tree().get_nodes_in_group("Spawner")[0].wave+1)+"/"+str(get_tree().get_nodes_in_group("Spawner")[0].tutorial_enemy_types.size())
	var corruption_value = get_child(0).value
	var slow_value = get_child(1).value
	if corruption_value < 50:
		get_child(5).visible = false
		get_child(4).visible = true
	if corruption_value > 50:
		get_child(5).visible = true
		get_child(4).visible = false
	if slow_value < 50:
		get_child(2).visible = false
		get_child(3).visible = true
	if slow_value > 50:
		get_child(2).visible = true
		get_child(3).visible = false
	
	score += passive_points_gain + (0.7-slow_value/get_child(1).max_value) * score_multiplier
	if score < 0:
		score = 0
	Global.score = score
		
	get_tree().get_nodes_in_group("ScoreLabel")[0].text = "Score "+str(roundf(score))
	get_tree().get_nodes_in_group("CurrencyLabel")[0].text = str(roundf(get_tree().get_nodes_in_group("Bastion")[0].currency))
	
	if muted == true:
		for x in get_tree().get_nodes_in_group("audio"):
			x.playing = false

func send_tutorial_cards(index):
	await get_tree().create_timer(1,false).timeout
	if get_tree().get_nodes_in_group("Spawner")[0].wave == tutorial_cards[index][1]:
		get_tree().get_nodes_in_group("bg_message_1")[0].visible = true
		get_tree().get_nodes_in_group("bg_message_2")[0].visible = true
		get_tree().get_nodes_in_group("TutorialCard")[0].visible = true
		get_tree().get_nodes_in_group("TutorialCard")[0].text = tutorial_cards[index][0]
		await get_tree().create_timer(5,false).timeout
		get_tree().get_nodes_in_group("bg_message_1")[0].visible = false
		get_tree().get_nodes_in_group("bg_message_2")[0].visible = false
		get_tree().get_nodes_in_group("TutorialCard")[0].visible = false
		if index+1 < tutorial_cards.size():
			send_tutorial_cards(index+1)
	else:
		send_tutorial_cards(index)
	
func instantiate_tower(type,index,location):
	var curr_tower
	match type:
		1:
			curr_tower = tower1.instantiate()
		2:
			curr_tower = tower2.instantiate()
		3:
			curr_tower = tower3.instantiate()
	curr_tower.position = location
	curr_tower.placed_location = index
	get_tree().get_nodes_in_group("Head")[0].add_child(curr_tower)

func initialize_tower_locations():
	max_towers = get_tree().get_nodes_in_group("TowerLocations")[0].get_children().size()
	for x in range(0,max_towers):
		get_tree().get_nodes_in_group("LocationsDropdown")[0].add_item(str(x+1))
		place_locations.append(false)
		hide_tower_locations()

func show_tower_locations():
	get_tree().get_nodes_in_group("LocationsDropdown")[0].visible = true
	for x in range(0,max_towers):
		get_tree().get_nodes_in_group("TowerLocations")[0].get_child(x).visible = true
	
func hide_tower_locations():
	get_tree().get_nodes_in_group("LocationsDropdown")[0].visible = false
	for x in range(0,max_towers):
		get_tree().get_nodes_in_group("TowerLocations")[0].get_child(x).visible = false
	

func _on_location_select_item_selected(index):
	var loc = get_tree().get_nodes_in_group("LocationsDropdown")[0].get_item_text(index)
	match loc:
		"NONE":
			get_tree().get_nodes_in_group("LocationsDropdown")[0].selected = 0
		"SELECT":
			get_tree().get_nodes_in_group("LocationsDropdown")[0].selected = 0
		_:
			if place_locations[int(loc)-1] == false:
				if get_tree().get_nodes_in_group("Bastion")[0].currency >= 500:
					instantiate_tower(tower_selected,int(loc)-1,get_tree().get_nodes_in_group("TowerLocations")[0].get_child(int(loc)-1).get_child(0).global_position)
					get_tree().get_nodes_in_group("Bastion")[0].currency -= 500
					place_locations[int(loc)-1] = true
				else:
					hide_tower_locations()
			get_tree().get_nodes_in_group("LocationsDropdown")[0].selected = 0
	hide_tower_locations()
		

func _on_pause_pressed():
	get_tree().paused = true

func _on_play_pressed():
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Scenes/level1.tscn")
	get_tree().paused = false

func _on_menu_button_pressed():
	get_tree().paused = true
	get_tree().get_nodes_in_group("game_menu")[0].visible = true

func _on_repair_button_pressed():
	if get_tree().get_nodes_in_group("Bastion")[0].currency > 1000:
		get_tree().get_nodes_in_group("Bastion")[0].currency -= 1000
		get_tree().get_nodes_in_group("RepairButton")[0].playing = true
		for x in range(0,get_tree().get_nodes_in_group("Tower").size()):
			var curr_tower = get_tree().get_nodes_in_group("Tower")[x]
			curr_tower.curr_resistance = curr_tower.tower_stats.resistance
			curr_tower.corrupted = false
			curr_tower.transformed = false
			curr_tower.fire_rate = curr_tower.tower_stats.fire_rate
			curr_tower.get_child(0).modulate = Color(1,1,1,1)
			curr_tower.get_child(3).visible = true
			curr_tower.get_child(4).visible = false

func _on_tower_1b_pressed():
	tower_selected = 1
	show_tower_locations()
	
	
func _on_tower_2b_pressed():
	tower_selected = 2
	show_tower_locations()


func _on_tower_3b_pressed():
	tower_selected = 3
	show_tower_locations()


func _on_mute_pressed():
	if muted == true:
		muted = false
	else:
		muted = true
