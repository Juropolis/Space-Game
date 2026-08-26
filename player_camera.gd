extends Camera2D

@onready var player = get_tree().get_first_node_in_group("player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		
	if is_instance_valid(player):
		global_position = player.global_position
		
	
