extends Node2D

@onready var player = get_parent()
@onready var hitbox = $Hitbox

func start_attack():
	hitbox.set_attacker(player)
	hitbox.new_attack()
	hitbox.set_multi_hit(false)
	visible = true
	hitbox.monitoring = true
	update_direction()
	print("attack placeholder")
	
func end_attack():
	visible = false
	hitbox.monitoring = false
	
func update_direction():
	# Updates position
	position.x = abs(position.x) * player.facing
	# Flips sprite
	scale.x = player.facing
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.set_attacker(player)
	# Hides attack
	visible = false
	# Turns off collisions
	hitbox.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
