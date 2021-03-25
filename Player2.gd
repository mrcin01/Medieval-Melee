extends KinematicBody2D

signal dead

export var maxSpeed = 300
var speed = maxSpeed
export var jumpForce = 750
export var gravity = 1000
var attackTimer = 0
var damageAnimationTime = 0
var player = 2
var forceX = 0
var forceY = 0
var dashCooldown = 0
var speedTimer = 0
var dive = false
var direction = 1
var dashesLeft = 0
var blocking : bool = false
var blocking_timer : int = 0
var alive = true
var startStun = 100

var blockCount = 3
var blockCooldown = 0

var vel : Vector2 = Vector2()

onready var sprite : AnimatedSprite = get_node("Sprite")
onready var healthbar = get_parent().get_node("healthbar_ui")
onready var hitbox : CollisionShape2D = get_node("Hitbox/HitboxShape")
onready var collisionBox = get_node("CollisionBox")

var hp : int = 20

var input_freeze : bool = false

func _physics_process(delta):
	if is_on_floor():
		vel.x = 0 + forceX

		if input_freeze == false:
			# Moving Left
			if Input.is_action_pressed("p2_move_left"):
				vel.x -= speed
			# Moving Right
			if Input.is_action_pressed("p2_move_right"):
				vel.x += speed


			# Jump
			if Input.is_action_pressed("p2_jump"):
				vel.y -= jumpForce
	else:
		vel.x += forceX
		if Input.is_action_pressed("p2_move_left"):
			vel.x -= speed/20
		# Moving Right
		if Input.is_action_pressed("p2_move_right"):
			vel.x += speed/20
	vel.x = min(max(-1*speed, vel.x), speed)

	if dive:
		vel.y = 1000
	else:
		# ForceY
		vel.y -= forceY

	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)

	# gravity
	if not dive:
		vel.y += gravity * delta
	
	
	

	
func _process(_delta):
	input_freeze = false
	
	if startStun > 0:
		startStun -= 1
		input_freeze = true
	# Sets direction 1 is right and -1 is left
	if sprite.flip_h:
		direction = 1
	else:
		direction = -1

	if Input.is_action_just_pressed("p2_attack") and attackTimer == 0 and not dive and input_freeze == false:
		sprite.play("attack")
		attackTimer = 40
	if dive and is_on_floor():
		speedTimer = 2
	if attackTimer > 0:
		attackTimer -= 1
	if damageAnimationTime > 0:
		damageAnimationTime -= 1
	if dashCooldown > 0:
		dashCooldown -= 1
	if speedTimer > 0:
		speedTimer -= 1
	if speedTimer == 1:
		speed = maxSpeed
		forceX = 0
		forceY = 0
		sprite.scale.y = 1
		sprite.scale.x = 1
		if not dive:
			vel.y = 0
		dive = false
		hitbox.disabled = true
	if is_on_floor():
		dashesLeft = 1
	if blocking_timer > 0:
		blocking_timer -= 1
		input_freeze = true
	if blocking_timer == 0:
		blocking = false
	if blockCooldown > 0:
		blockCooldown -= 1
	if blockCooldown == 1:
		blockCount += 1
		healthbar.update_blockbar2(blockCount)
		if blockCount < 3:
			blockCooldown = 300

	if dive:
		hitbox.disabled = false
	else:
		# Enables hitbox for 5 frames of the attack
		if attackTimer == 15:
			hitbox.disabled = false
		if attackTimer == 10:
			hitbox.disabled = true

	# Blocking attacks
	if Input.is_action_just_pressed("p2_block") and not blocking and attackTimer == 0 and blockCount > 0 and not dive and input_freeze == false:
		blocking = true
		blockCount -= 1
		healthbar.update_blockbar2(blockCount)
		if blockCooldown == 0:
			blockCooldown = 300
		blocking_timer = 20
		input_freeze = true
	

	dash()
	animations()

func _on_HurtBox_area_entered(area):
	print("The hit box: ", area.name, " is overlapping")
	var regex = RegEx.new()
	regex.compile("Dagger")
	if (area.name == "Hitbox" or regex.search(area.name) or area.name == "DownThrust") and not blocking:
		hp -= 1
		print("Health: ", hp)
		sprite.play("damaged")
		damageAnimationTime = 5
		healthbar.update_healthbar2(hp)
	

func animations():

	if vel.x > 0:
		sprite.flip_h = true
		hitbox.position.x = 28
		if attackTimer == 0 and is_on_floor():
			sprite.play("run")
	elif vel.x < 0:
		sprite.flip_h = false
		hitbox.position.x = -28
		if attackTimer == 0 and is_on_floor():
			sprite.play("run")
	elif attackTimer == 0 and is_on_floor():
		sprite.play("idle")

	if dive:
		sprite.play("jump")
		sprite.rotation_degrees = direction * 50
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

func dash():
	if Input.is_action_just_pressed("p2_dash_left") and dashCooldown == 0 and input_freeze == false:
		dashCooldown = 30
		speedTimer = 10
		speed = 1200
		forceX = -10000
		sprite.scale.y = 0.65
	
	if Input.is_action_just_pressed("p2_dash_right") and dashCooldown == 0 and input_freeze == false:
		dashCooldown = 30
		speedTimer = 10
		speed = 1200
		forceX = 10000
		sprite.scale.y = 0.65
	
	if Input.is_action_just_pressed("p2_dash_up") and dashesLeft > 0 and dashCooldown == 0 and input_freeze == false:
		dashCooldown = 30
		speedTimer = 10
		speed = 1200
		forceY = 500
		sprite.scale.x = 0.65
		dashesLeft -= 1
	if Input.is_action_just_pressed("p2_dash_down") and attackTimer == 0 and dashCooldown == 0 and input_freeze == false:
		dashCooldown = 30
		speedTimer = 60
		speed = 1200
		forceX = direction * 50
		dive = true

		
		sprite.scale.x = 0.65
