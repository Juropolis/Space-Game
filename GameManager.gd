extends Node

var player_health = 3
var player_max_health = 3

var player_dash_charges = 3
var player_max_dash_charges = 3



func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Makes sure this isn't affected by pauses
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
