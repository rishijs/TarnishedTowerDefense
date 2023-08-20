extends CanvasLayer

func _ready():
	pass

func _process(delta):
	pass


func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()


func _on_resume_pressed():
	get_tree().paused = false
	visible = false
