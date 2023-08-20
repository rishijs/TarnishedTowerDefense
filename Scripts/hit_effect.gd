extends Sprite2D

var lifetime = 0.1
var parent_enemy

func _ready():
	if get_tree().get_nodes_in_group("Interface")[0].muted == false:
		get_child(0).playing = true
	await get_tree().create_timer(lifetime,false).timeout
	queue_free()

func _process(delta):
	pass
