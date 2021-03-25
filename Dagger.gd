extends Area2D

var speed = 650
onready var direction = get_parent().get_node("Player1").direction


func _physics_process(delta):
	position += transform.x * speed * delta * direction
	$Sprite.rotation_degrees += 15

func _on_Dagger_area_entered(area):
	if area.name == "HurtboxP2":
		queue_free()
