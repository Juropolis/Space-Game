extends GravityCharacter

var player
@onready var hurtbox = $Hurtbox

var team = "enemy"

func physics_update(delta):
	pass
	
	
func hit_received():
	print("Enemy hit")
	hurtbox.make_invincible(20.0)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	print(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
