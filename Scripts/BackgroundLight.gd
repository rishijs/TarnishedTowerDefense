extends PointLight2D

func _ready():
	change_color()


func _process(delta):
	pass

func change_color():
	
	var prev_color = color
	for x in range(0,9):
		for y in range(0,9):
			await get_tree().create_timer(0.1).timeout
			var blue_val = randi_range(0,9)
			var new_color = Color(0.01*x,0.01*y,0.01*blue_val,1)
			new_color = new_color.darkened(0.35)
			color = prev_color.lerp(new_color,0.1)
			prev_color = color
				
	change_color()
	
