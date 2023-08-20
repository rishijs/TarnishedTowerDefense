extends CanvasLayer

func _ready():
	pass


func _process(delta):
	pass


func _on_button_pressed():
	#play
	get_tree().change_scene_to_file("res://Scenes/level1.tscn")


func _on_button_2_pressed():
	#credits
	get_tree().change_scene_to_file("res://Scenes/contributions.tscn")
