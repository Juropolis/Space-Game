extends Node2D
class_name Attack

var attack_damage = 1
@onready var parent = get_parent()
@onready var hitbox = $Hitbox

func start_attack():
	hitbox.set_attacker(parent)
	hitbox.new_attack()
	hitbox.set_multi_hit(false)
	hitbox.damage = attack_damage
	visible = true
	hitbox.monitoring = true
	update_direction()
	
func end_attack():
	visible = false
	hitbox.monitoring = false
	
func update_direction():
	# Updates position
	position.x = abs(position.x) * parent.facing
	# Flips sprite
	scale.x = parent.facing
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hides attack
	visible = false
	# Turns off collisions
	hitbox.monitoring = false
	
func set_damage(damage):
	attack_damage = damage



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
