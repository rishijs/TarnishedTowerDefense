extends Camera2D

var starting_height
var starting_width
var initial_zoom_x
var initial_zoom_y

var initial_mouse_offset = Vector2(575,325)
var mouse_offset = Vector2(575,325)

func _ready():
	get_tree().get_root().connect("size_changed", on_resize)
	starting_height = ProjectSettings.get_setting("display/window/size/viewport_height") * 1.0
	starting_width = ProjectSettings.get_setting("display/window/size/viewport_width") * 1.0
	initial_zoom_x = zoom.x
	initial_zoom_y = zoom.y
	on_resize()

func on_resize():
	var currentScreenX = DisplayServer.window_get_size().x * 1.0
	var currentScreenY = DisplayServer.window_get_size().y * 1.0 
	
	zoom.x = initial_zoom_x * currentScreenX/starting_width
	zoom.y = initial_zoom_y * currentScreenY/starting_height
	
	mouse_offset.x *= initial_mouse_offset.x * currentScreenX/starting_width
	mouse_offset.y *= initial_mouse_offset.y * currentScreenX/starting_width
	
	
	
