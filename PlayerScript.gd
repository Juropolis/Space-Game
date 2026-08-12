extends GravityCharacter
@onready var hurtbox = $Hurtbox
@onready var basic_attack = $BasicAttack


const GRAVITY = 900.0
const FALLING_GRAVITY_MULTIPLIER = 1.3
const TERMINAL_VELOCITY = 450
const SPEED = 200.0
const JUMP_FORCE = 500.0
const JUMP_MULTIPLIER = 0.8
const DASH_SPEED = 400.0
const DASH_DECELERATION = 2200
const WALK_ACCELERATION = 2000
const DASH_CHAIN_WINDOW = 0.20

#Times
const COYOTE_TIME = 0.15   # Seconds of coyote time
const JUMP_BUFFER_TIME = 0.1	# Seconds of jump buffer time
const WALL_STICK_TIME = 0.1
const DASH_TIME = 0.5
const BASIC_ATTACK_TIME = 0.25
const DASH_RECHARGE_TIME = 3

#Timers
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var wall_timer = 0.0
var dash_timer = 0.0
var dash_recharge_timer = DASH_RECHARGE_TIME
var DASH_COOLDOWN = 0.25
var dash_cooldown = 0


var can_chain_dash = false
var dash_direction = 0
var jump_type = "regular"
var wall_running = false
var facing = 1
var player_state = "neutral"
var attack_timer = 0.0
var dash_speed = 0.0

var relative_position = 0
var last_up_angle = 0

var dash_start_timestamp: int = 0

@onready var HUD = $"../HUD"

var team = "player"


func physics_update(delta):
	
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
			handle_dash_input(input_direction)
			handle_dash(delta)
			
			#handle_jump() # If i want dash-jump cancel
			#handle_attack_input() # If i want dash-attack cancels

		"attacking":
			#Add handle attack input if you want normal cancelling
			handle_movement(input_direction, delta)
			handle_attack_timer(delta)
	
	#Functions that always apply 
	handle_dash_cooldown(delta)
	
	

func handle_movement(input_direction, delta):
	
	#for is_on_floor checks

	#Mess around with this value if cube starts bouncing or glitching
	floor_snap_length = 0
	
	
	
	#If you're in a gravity field
	if active_gravity_fields.size() > 0:
		#Movement code
		var current_tangent_speed = velocity.dot(surface_tangent)
		
		var current_normal_velocity = velocity - surface_tangent * current_tangent_speed
		
		if is_on_floor():
			if input_direction != 0:
				var target_tangent_speed = input_direction * SPEED
				current_tangent_speed = move_toward(current_tangent_speed, target_tangent_speed, delta * WALK_ACCELERATION)
			elif input_direction == 0:
				#Slows the player down to a stop when arrows released
				current_tangent_speed = move_toward(current_tangent_speed, 0.0, WALK_ACCELERATION * delta)
	
		else:
			if input_direction != 0:
				#If trying moving with the dash
				if input_direction == sign(current_tangent_speed):
					#If moving slower than regular speed allow forward movement
					if abs(current_tangent_speed) < SPEED:
						var target_tangent_speed = input_direction * SPEED
						current_tangent_speed = move_toward(current_tangent_speed, target_tangent_speed, delta * WALK_ACCELERATION)
				#If trying to move against the dash
				elif input_direction == -sign(current_tangent_speed):
					var target_tangent_speed = input_direction * SPEED
					current_tangent_speed = move_toward(current_tangent_speed, target_tangent_speed, delta * WALK_ACCELERATION)
					
				
		
		velocity = (surface_tangent * current_tangent_speed) + current_normal_velocity
			
			
		
		
	# Move along the surface, not against gravity
	

		
		
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
	if Input.is_action_just_pressed("basic_attack"):
		player_state = "attacking"
		attack_timer = BASIC_ATTACK_TIME
		basic_attack.start_attack()

	
#how violent
func handle_attack_timer(delta):
	#velocity.x = move_toward(velocity.x, 0, DASH_DECELERATION * delta)
	
	# Core
	attack_timer -= delta
	if attack_timer <= 0:
		player_state = "neutral"
		basic_attack.end_attack()


#Out of commision for now lmfao
func handle_dash_input(input_direction):
	if Input.is_action_just_pressed("dash") and GameManager.player_dash_charges > 0 and dash_cooldown <= 0:
		
		if player_state == "dashing":
			if can_chain_dash == false:
				return
			
			dash_speed += 150
		
		elif player_state == "neutral":
			dash_speed = DASH_SPEED
			
		GameManager.player_dash_charges -= 1
		if (input_direction != 0):
			dash_direction = input_direction 
		else:
			dash_direction = facing
			
		player_state = "dashing"
		
		can_chain_dash = false
		
		dash_start_timestamp = Time.get_ticks_msec() 
		
		# Base wait time is 0.25 seconds (250ms)
		var adaptive_wait_time = 0

		if dash_speed > DASH_SPEED:
			# Adds a small delay for every 150 speed added to help visually
			var speed_modifier = (dash_speed - DASH_SPEED) / 150.0
			adaptive_wait_time += (speed_modifier * 0.06)
			
		dash_timer = DASH_TIME + adaptive_wait_time
		
		$DashFlashTimer.stop()
		$DashFlashTimer.start(dash_timer - DASH_CHAIN_WINDOW)
		
		
func handle_dash(delta):
	dash_timer -= delta


	var target_dash_speed = dash_direction * dash_speed
		
	var tangent_speed = velocity.dot(surface_tangent)
	var normal_velocity = velocity - surface_tangent * tangent_speed

	velocity = surface_tangent * target_dash_speed + normal_velocity

	if dash_timer <= 0:
		player_state = "neutral"
		dash_speed = DASH_SPEED
		can_chain_dash = false
		$AnimationPlayer.speed_scale = 1.0
		dash_cooldown = DASH_COOLDOWN
		
func handle_dash_recharge(delta):
	if GameManager.player_dash_charges < GameManager.player_max_dash_charges:
		dash_recharge_timer -= delta
		if dash_recharge_timer <= 0:
			GameManager.player_dash_charges += 1
			dash_recharge_timer = DASH_RECHARGE_TIME
			print("Dash ", GameManager.player_dash_charges, " charged!")
			
func _on_dash_flash_timeout():
	$AnimationPlayer.speed_scale = 1.0
	if player_state == "dashing" && GameManager.player_dash_charges > 0:
		
		# Calculates how much time is left in the total dash
		var time_passed = (Time.get_ticks_msec() - dash_start_timestamp) / 1000.0
		var remaining_window_time = dash_timer
		
		# Speeds up the animation based on the time it has to play
		$AnimationPlayer.speed_scale = 1.0 / remaining_window_time
		
		can_chain_dash = true
			
		$AnimationPlayer.play("dash_flash")
		
func handle_dash_cooldown(delta):
	dash_cooldown -= delta


func hit_received():
	if GameManager.player_health > 0:
		GameManager.player_health -= 1
		HUD.update_health(GameManager.player_health)
		print(GameManager.player_health, " hp")
		hurtbox.make_invincible(2.0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.material.set_shader_parameter("flash", false)
	$DashFlashTimer.timeout.connect(_on_dash_flash_timeout)
	HUD.update_health(GameManager.player_health)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
