extends GravityCharacter

@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox

var HEALTH = 100
var MOVE_SPEED = 70
var MOVE_ACCELERATION = 1000

var move_speed = MOVE_SPEED
var health = HEALTH
var team = "enemy"
var facing = 1

func physics_update(delta):
	handle_movement(delta)
	#update_facing()
	
		
#func update_facing():
	# Velocity is always tiny, rarely exactly 0
	if velocity.length() > 0.1:
		if velocity.dot(surface_tangent) > 0.1:
			facing = 1
		else: 
			facing = -1
	
func handle_movement(delta):
	calculate_directional_speeds()
	current_tangent_speed = move_toward(current_tangent_speed, move_speed, delta * MOVE_ACCELERATION)
	velocity = (surface_tangent * current_tangent_speed) + current_normal_velocity
	
func hit_received(damage):
	health -= damage
	if health <= 0:
		die()
	print(health)
	
func die():
	print("Enemy defeated")
	# Death animation
	queue_free()
	
func set_contact_hitbox():
	#Contact hitbox
	hitbox.set_attacker(self)
	hitbox.set_multi_hit(true)
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_contact_hitbox()
	var random_number = randi_range(1, 2)
	if random_number == 1:
		facing = 1
	else:
		facing = -1
	move_speed *= facing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
