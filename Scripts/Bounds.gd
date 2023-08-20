extends Area2D


func _ready():
	pass


func _process(delta):
	pass


func _on_body_entered(body):
	if body.get_groups()[0] == "Projectile":
		body.rebound = true
