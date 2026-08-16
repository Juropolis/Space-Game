extends GravityCharacter

var player
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox
var HEALTH = 100
var health = HEALTH

var team = "enemy"

func physics_update(delta):
	pass
	
	
func hit_received(damage):
	health -= damage
	if health <= 0:
		die()
	print(health)
	
func die():
	print("Enemy defeated")
	# Death animation
	queue_free()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.set_attacker(self)
	hitbox.set_multi_hit(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
