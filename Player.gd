extends KinematicBody2D
class_name Player

export var speed = 200
export var jumpForce = 500
export var gravity = 800
var attackTimer = 0

var vel : Vector2 = Vector2()

onready var sprite : AnimatedSprite = get_node("Sprite")
onready var slash : Sprite = get_node("Slash")

func _physics_process(delta):

	vel.x = 0

	#var collision = move_and_collide(vel * delta)
	#if collision:
	#	print("I collided with ", collision.collider.name)

	# Moving Left
	if Input.is_action_pressed("p1_move_left") and is_on_floor():
		vel.x -= speed
	# Moving Right
	if Input.is_action_pressed("p1_move_right") and is_on_floor():
		vel.x += speed
	# Moving Left in air
	if Input.is_action_pressed("p1_move_left") and is_on_floor() == false:
		vel.x -= speed / 1.4
	# Moving Right in air
	if Input.is_action_pressed("p1_move_right") and is_on_floor() == false:
		vel.x += speed / 1.4


	# Jump
	if Input.is_action_pressed("p1_jump") and is_on_floor():
		vel.y -= jumpForce

	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)

	# gravity
	vel.y += gravity * delta
	
	# Turns the player depending on which way he is facing
	

	
func _process(delta):
	if Input.is_action_pressed("p1_attack") and attackTimer == 0:
		sprite.play("attack")
		attackTimer = 20
	
	if attackTimer > 0:
		attackTimer -= 1
	
	# Turns the slash image on and off during attack
	if attackTimer == 2:
		slash.visible = true
	if attackTimer == 0:
		slash.visible = false

	# Change Directions
	if vel.x > 0:
		sprite.flip_h = true
		slash.flip_h = true
		slash.position.x = -10
		if attackTimer == 0:
			sprite.play("run")
	elif vel.x < 0:
		sprite.flip_h = false
		slash.flip_h = false
		slash.position.x = -45
		if attackTimer == 0:
			sprite.play("run")
	elif attackTimer == 0:
		sprite.play("idle")
