extends Node2D



onready var healthbar1 = $"HP Bar 1"
onready var healthbar2 = $"HP Bar 2"
onready var blockbar1 = $"Block Bar 1"
onready var blockbar2 = $"Block Bar 2"

func _ready():
	healthbar1.max_value = 20
	healthbar2.max_value = 20
	blockbar1.max_value = 3
	blockbar2.max_value = 3
	

func _process(_delta):
	global_rotation = 0
	
func update_healthbar1(value):
	healthbar1.value = value
	
func update_healthbar2(value):
	healthbar2.value = value
	
func update_blockbar1(value):
	blockbar1.value = value
	
func update_blockbar2(value):
	blockbar2.value = value

