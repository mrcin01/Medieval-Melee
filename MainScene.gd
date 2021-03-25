extends Node2D

var timer = 0
var x1 = 375
var x2 = 205
var y = 520
var timerAnimation = 0.00
var startTimer = 100
var titleAnimation = 0.00

func _process(_delta):
	
	if startTimer > 0:
		startTimer -= 1
		if titleAnimation < 1:
			titleAnimation += .02
		$Title.percent_visible = titleAnimation
	if startTimer == 1:
		$Title.rect_position.x = 3000
	
	if timer > 0:
		timer -= 1
		if timerAnimation < 1:
			timerAnimation += .02
		$KnightSlain.percent_visible = timerAnimation
		$MonsterSlain.percent_visible = timerAnimation
	if timer == 1:
		get_tree().reload_current_scene()

func _on_Player1_dead():
	timer = 100
	$KnightSlain.rect_position.x = x1
	$KnightSlain.rect_position.y = y
	
func _on_Player2_dead():
	timer = 100
	$MonsterSlain.rect_position.x = x2
	$MonsterSlain.rect_position.y = y
