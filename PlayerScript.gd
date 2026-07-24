extends CharacterBody2D


const GRAVITY = 900.0
const FALLING_GRAVITY_MULTIPLIER = 1.3
const TERMINAL_VELOCITY = 450
const SPEED = 200.0
const JUMP_FORCE = 500.0
const JUMP_MULTIPLIER = 0.8
const DASH_SPEED = 400.0
const DASH_DECELERATION = 2200
const WALK_ACCELERATION = 1000

#Times
const COYOTE_TIME = 0.15   # Seconds of coyote time
const JUMP_BUFFER_TIME = 0.1	# Seconds of jump buffer time
const WALL_STICK_TIME = 0.1
const DASH_TIME = 0.2
const MSLASH_TIME = 0.5
const DASH_RECHARGE_TIME = 3

#Timers
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var wall_timer = 0.0
var dash_timer = 0.0
var dash_recharge_timer = DASH_RECHARGE_TIME

var dash_direction = 0
var jump_type = "regular"
var wall_running = false
var facing = 1
var player_state = "neutral"
var attack_timer = 0.0

var active_gravity_fields: Array[Area2D] = []
var relative_position = 0
var total_pull = Vector2.ZERO
var rotation_speed = 6
var down_angle = 0
var up_angle = 0
var last_up_angle = 0
var total_gravity_direction = total_pull.normalized()
var surface_tangent = Vector2.ZERO
var dash_charges = 1
var max_dash_charges = 3


func _physics_process(delta):
	
	apply_gravity(delta)

	if total_pull.length() > 0:
		up_direction = -total_pull.normalized()

	var input_direction = Input.get_axis("left", "right")
	if input_direction != 0:
		facing = input_direction
	
	update_timers(delta)
	
	match player_state:
		"neutral":
			handle_movement(input_direction, delta)
			handle_jump()
			handle_dash_input(input_direction)
			handle_dash_recharge(delta)
			handle_attack_input()

		"dashing":
			handle_dash(delta)
			
			#handle_jump() # if you want dash-jump cancel
			#handle_attack_input()

		#"attacking":
			#Add handle attack input if you want normal cancelling
			#handle_attack(delta)
	
	#Functions that always apply 
	handle_rotation(delta)
	
	
	move_and_slide()
	
	
func apply_gravity(delta):
	
	total_pull = Vector2.ZERO
	
	for gravity_area in active_gravity_fields:
		
		var offset = gravity_area.global_position - global_position
		var distance = offset.length()
		
		# Avoid division by zero if player is exactly on the gravity source
		if distance == 0:
			continue
					   
		var local_direction = offset.normalized()

		#change 
		
		
		var max_radius = gravity_area.gravity_radius
		var gravity_strength = gravity_area.gravity_strength
		
		# Only applies if player is inside the gravity field
		if distance < max_radius:
			var scale_factor = 1.0 - (distance / max_radius)
			var local_pull = gravity_strength * scale_factor
			
			total_pull += local_direction * local_pull
	
	velocity += total_pull * delta
	
	#Calculates all new directions due to gravity changing
	if total_pull.length() > 0:
		total_gravity_direction = total_pull.normalized()
		up_direction = -total_gravity_direction
		down_angle = total_gravity_direction.angle()
		surface_tangent = Vector2(
			-total_gravity_direction.y,
			 total_gravity_direction.x
		)
		
	
	
func handle_movement(input_direction, delta):
	
	#for is_on_floor checks

	#Mess around with this value if cube starts bouncing or glitching
	floor_snap_length = 0
	
	
	
	#If you're in a gravity field
	if active_gravity_fields.size() > 0:
		#Movement code
		var current_tangent_speed = velocity.dot(surface_tangent)
		
		var current_normal_velocity = velocity - surface_tangent * current_tangent_speed
		
		if input_direction != 0:
			var target_tangent_speed = -input_direction * SPEED
			current_tangent_speed = move_toward(current_tangent_speed, target_tangent_speed, delta * WALK_ACCELERATION)
		
		#If you're touching a planet	
		else:
			if is_on_floor():
				#Slows the player down to a stop when arrows released
				current_tangent_speed = move_toward(current_tangent_speed, 0.0, WALK_ACCELERATION * delta)
		
		velocity = (surface_tangent * current_tangent_speed) + current_normal_velocity
			
			
		
		
	# Move along the surface, not against gravity
	

func handle_rotation(delta):
	if active_gravity_fields.size() > 0:
		up_angle = down_angle - PI/2
		rotation = rotate_toward(rotation, up_angle, rotation_speed * delta)
		
		
func hitbox_flip():
	$HitboxPivot.scale.x = facing
		
		
func update_timers(delta):
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# Coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta


func handle_jump():

	if jump_buffer_timer > 0 and coyote_timer > 0:
		if total_pull.length() > 0:
			velocity += -total_pull.normalized() * JUMP_FORCE
			
		
		jump_buffer_timer = 0
		coyote_timer = 0
	
	#Could be improved to have more of an effect, come back to this at some point
	if Input.is_action_just_released("jump"):
		var current_normal_speed = velocity.dot(total_gravity_direction)
		if current_normal_speed < 0:
			velocity -= total_gravity_direction * (current_normal_speed * 0.5)



func handle_attack_input():
	if Input.is_action_just_pressed("mSlash"):
		player_state = "attacking"
		attack_timer = MSLASH_TIME
	
#how violent
func handle_attack(delta):
	velocity.x = move_toward(velocity.x, 0, DASH_DECELERATION * delta)
	
	attack_timer -= delta
	if attack_timer <= 0:
		player_state = "neutral"


#Out of commision for now lmfao
func handle_dash_input(input_direction):
	if Input.is_action_just_pressed("dash") && dash_charges > 0:
		dash_charges -= 1
		player_state = "dashing"
		dash_timer = DASH_TIME
		if (input_direction != 0):
			dash_direction = input_direction 
		else:
			dash_direction = facing
		
		var target_dash_speed = -dash_direction * DASH_SPEED
		
		var tangent_speed = velocity.dot(surface_tangent)
		var normal_velocity = velocity - surface_tangent * tangent_speed

		velocity = surface_tangent * target_dash_speed + normal_velocity
		
		
		
		
		
		
func handle_dash(delta):
	dash_timer -= delta

	var normal_velocity = velocity - surface_tangent * velocity.dot(surface_tangent)

	velocity = surface_tangent * (-dash_direction * DASH_SPEED) + normal_velocity

	if dash_timer <= 0:
		player_state = "neutral"
		
		
func handle_dash_recharge(delta):
	if dash_charges < max_dash_charges:
		dash_recharge_timer -= delta
		if dash_recharge_timer <= 0:
			dash_charges = dash_charges + 1
			dash_recharge_timer = DASH_RECHARGE_TIME
			print("Dash ", dash_charges, " charged!")
	

#Adds planets to the active list when in gravity range
func _on_gravity_detector_area_entered(area: Area2D):
	if area.has_method("get_gravity_strength"):
		active_gravity_fields.append(area)

#Removes planets from the active list when out of gravity range
func _on_gravity_detector_area_exited(area: Area2D):
	if area in active_gravity_fields:
		active_gravity_fields.erase(area)
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
