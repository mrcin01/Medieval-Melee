extends KinematicBody2D

signal dead

export var maxSpeed = 300
var speed = maxSpeed
export var jumpForce = 750
export var gravity = 1000
var attackTimer = 0
var damageAnimationTime = 0
var hp : int = 20
var dashCooldown = 40
var speedTimer = 0
var dive = false
var daggerTimer = 0
var alive = true
var startStun = 100

const Dagger = preload("res://Dagger.tscn")

var vel : Vector2 = Vector2()

var hitboxRotationLeft = 36.4
var hitboxRotationRight = -225.4

onready var sprite : AnimatedSprite = get_node("Sprite")
onready var attackArea : Area2D = get_node("Hitbox")
onready var slash : Sprite = get_node("Hitbox/Slash")
onready var hitbox : CollisionShape2D = get_node("Hitbox/HitboxShape")
onready var downHitbox : CollisionShape2D = get_node("DownThrust/DownThrustShape")
onready var healthbar = get_parent().get_node("healthbar_ui")
onready var player2 = get_parent().get_node("Player2")
onready var throwPoint = get_node("ThrowPoint")
onready var collisionBox = get_node("CollisionShape2D")
var direction = 1

var blocking : bool = false
var blocking_timer : int = 0
var input_freeze : bool = false
var grabTimer = 0
var forceX = 0
var forceY = 0

var blockCount = 3
var blockCooldown = 0


func _physics_process(delta):

	if is_on_floor():
		vel.x = 0 + forceX

		if input_freeze == false:
			# Moving Left
			if Input.is_action_pressed("p1_move_left"):
				vel.x -= speed
			# Moving Right
			if Input.is_action_pressed("p1_move_right"):
				vel.x += speed


			# Jump
			if Input.is_action_pressed("p1_jump"):
				vel.y -= jumpForce
				if attackTimer == 0:
					sprite.play("jump")
	else:
		vel.x += forceX
		if Input.is_action_pressed("p1_move_left"):
			vel.x -= speed/20
		# Moving Right
		if Input.is_action_pressed("p1_move_right"):
			vel.x += speed/20
	vel.x = min(max(-1*speed, vel.x), speed)

	
	# ForceY
	vel.y -= forceY

	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)

	# gravity
	vel.y += gravity * delta
	
	
func _process(_delta):

	input_freeze = false
	
	if startStun > 0:
		startStun -= 1
		input_freeze = true
	
	if sprite.flip_h:
		direction = 1
	else:
		direction = -1

	throwPoint.position.x = direction * 20
	
	if dive and is_on_floor():
		speedTimer = 2

	# Keeps track of timers
	if attackTimer > 0:
		attackTimer -= 1
	if damageAnimationTime > 0:
		damageAnimationTime -= 1
	if grabTimer > 0:
		grabTimer -= 1
		input_freeze = true
	if blocking_timer > 0:
		blocking_timer -= 1
		input_freeze = true
	if blocking_timer == 0:
		blocking = false
	if speedTimer > 0:
		speedTimer -= 1
	if speedTimer == 1:
		speed = maxSpeed
		forceX = 0
		sprite.scale.y = 1
		dive = false
		downHitbox.disabled = true
	if dashCooldown > 0:
		dashCooldown -= 1
	if daggerTimer > 0:
		daggerTimer -= 1
	if blockCooldown > 0:
		blockCooldown -= 1
	if blockCooldown == 1:
		blockCount += 1
		healthbar.update_blockbar1(blockCount)
		if blockCount < 3:
			blockCooldown = 300


	# Handle grabbed case
	if grabTimer == 58:
		forceY = 1000
		if player2.get_node("Sprite").flip_h == true:
			direction = 1
		else:
			direction = -1
		
	if grabTimer == 57:
		forceY = 0
		vel.x = 500 * direction
	
	# Blocking attacks
	if Input.is_action_just_pressed("p1_block") and not blocking and attackTimer == 0 and blockCount > 0 and not dive and input_freeze == false:
		blocking = true
		blockCount -= 1
		healthbar.update_blockbar1(blockCount)
		if blockCooldown == 0:
			blockCooldown = 300
		blocking_timer = 20
		input_freeze = true

	# Turns the slash image on and off during attack as well as enabling hitbox
	if attackTimer == 2:
		slash.visible = true
		hitbox.disabled = false
	if attackTimer == 0:
		slash.visible = false
		hitbox.disabled = true 

	if Input.is_action_just_pressed("p1_attack") and attackTimer == 0 and not dive and not input_freeze:
		sprite.play("attack")
		attackTimer = 20
	
	if Input.is_action_just_pressed("p1_throw") and daggerTimer == 0:
		dagger()
	
	if dive:
		downHitbox.disabled = false
	
	dash()
	animations()

func dagger():
	var b = Dagger.instance()
	owner.add_child(b)
	b.transform = throwPoint.global_transform
	daggerTimer = 120

func animations():

	# Change Directions
	# Facing Right
	if vel.x > 0:
		sprite.flip_h = true
		slash.flip_h = true
		slash.position.x = -15
		hitbox.position.x = 14
		hitbox.rotation = hitboxRotationRight
		if attackTimer == 0:
			sprite.play("run")
	# Facing Left
	elif vel.x < 0:
		sprite.flip_h = false
		slash.flip_h = false
		slash.position.x = -50
		hitbox.position.x = -22.5
		hitbox.rotation = hitboxRotationLeft
		if attackTimer == 0:
			sprite.play("run")
	elif attackTimer == 0:
		sprite.play("idle")
	if dive:
		sprite.play("jump")
		sprite.rotation_degrees = direction * 130
	else:
		sprite.rotation_degrees = 0

	if blocking:
		sprite.play("block")
	if damageAnimationTime > 0:
		sprite.play("damaged")
		
	if hp <= 0:
		if alive:
			alive = false
			emit_signal("dead")
		sprite.play("dead")
		collisionBox.position.y = -12
		input_freeze = true


func _on_Hurtbox_area_entered(area):
	if area.name == "Hitbox" and not blocking:
		if player2.dive:
			hp -= 1
		else:
			hp -= 2
			grabTimer = 60
		print("Health: ", hp)
		sprite.play("damaged")
		damageAnimationTime = 10
		healthbar.update_healthbar1(hp)

func dash():
	if Input.is_action_just_pressed("p1_dash_left") and dashCooldown == 0 and not input_freeze:
		dashCooldown = 40
		speedTimer = 10
		speed = 1200
		forceX = -10000
		sprite.scale.y = 0.65
	
	if Input.is_action_just_pressed("p1_dash_right") and dashCooldown == 0 and not input_freeze:
		dashCooldown = 40
		speedTimer = 10
		speed = 1200
		forceX = 10000
		sprite.scale.y = 0.65
	if Input.is_action_just_pressed("p1_down_thrust") and attackTimer == 0 and not input_freeze and not is_on_floor():
		dashCooldown = 40
		speedTimer = 60
		dive = true
