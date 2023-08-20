extends Area2D

var max_health = 100
var current_health = 100

var currency = 500
var currency_per_second = 0.3
var max_money_multiplier = 1.2

var enemies_killed = 0
var enemies_sacrificed = 0

var last_breath = false
var last_breath_time = 20

var wave_in_progress = false

func _ready():
	pass

#if all enemies defeated win

func _process(delta):
	
	#print(enemies_killed," ", enemies_sacrificed, " ", get_tree().get_nodes_in_group("Spawner")[0].enemies_spawned)
	if current_health <= 0 && last_breath == false:
		current_health = 0
		last_breath_countdown(last_breath_time)
		last_breath = true
		self.modulate *= 0.95
	
	if current_health >= max_health && last_breath == true:
		get_tree().change_scene_to_file("res://Scenes/victory.tscn")
	
	if enemies_killed+enemies_sacrificed != 0:
		if enemies_killed+enemies_sacrificed >= get_tree().get_nodes_in_group("Spawner")[0].enemies_spawned && wave_in_progress == true:
			get_tree().get_nodes_in_group("Spawner")[0].ready_spawner = true
			wave_in_progress = false
			enemies_killed = 0
			enemies_sacrificed = 0
			get_tree().get_nodes_in_group("Spawner")[0].enemies_spawned = 0

	update_healthbar()
	update_currency()

func last_breath_countdown(time_left):
	get_child(3).visible = true
	get_child(3).text = str(time_left)
	if time_left < 3:
		get_child(3).modulate = Color(255,0,0,1)
	await get_tree().create_timer(1,false).timeout
	if time_left == 0:
		get_child(3).text = str(time_left)
		get_tree().change_scene_to_file("res://Scenes/defeat.tscn")
	else:
		last_breath_countdown(time_left-1)
	
func update_currency():
	currency += currency_per_second + max_money_multiplier * (1-get_tree().get_nodes_in_group("CorruptionSlider")[0].value/get_tree().get_nodes_in_group("CorruptionSlider")[0].max_value)
	
func update_healthbar():
	get_child(1).max_value = max_health
	get_child(1).value = current_health


func _on_body_entered(body):
	if body.get_groups()[0] == "Projectile":
		body.queue_free()
