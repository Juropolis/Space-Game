extends CharacterBody2D
class_name GravityCharacter

var active_gravity_fields: Array[Area2D] = []
var total_pull = Vector2.ZERO
var total_gravity_direction = total_pull.normalized()
var surface_tangent = Vector2.ZERO
var rotation_speed = 6
var down_angle = 0
var up_angle = 0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if total_pull.length() > 0:
		up_direction = -total_pull.normalized()
	
	physics_update(delta)
	
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

		var max_radius = gravity_area.gravity_radius
		var gravity_strength = gravity_area.gravity_strength
		
		# Only applies if player is inside the gravity field
		if distance < max_radius:
			var scale_factor = 1.0 - (distance / max_radius)
			var local_pull = gravity_strength * scale_factor
			
			total_pull += local_direction * local_pull
	
	velocity += total_pull * delta
	
	# Calculates all new directions due to gravity changing
	if total_pull.length() > 0:
		total_gravity_direction = total_pull.normalized()
		up_direction = -total_gravity_direction
		down_angle = total_gravity_direction.angle()
		surface_tangent = Vector2(
			total_gravity_direction.y,
			-total_gravity_direction.x
		)

# Rotates the player to match the direction of gravitys pull
func handle_rotation(delta):
	if active_gravity_fields.size() > 0:
		up_angle = down_angle - PI/2
		rotation = rotate_toward(rotation, up_angle, rotation_speed * delta)
	
	
# Adds planets to the active list when in gravity range
func _on_gravity_detector_area_entered(area: Area2D):
	if area.has_method("get_gravity_strength"):
		active_gravity_fields.append(area)

# Removes planets from the active list when out of gravity range
func _on_gravity_detector_area_exited(area: Area2D):
	if area in active_gravity_fields:
		active_gravity_fields.erase(area)
		
# Placeholder for inheritance
func physics_update(delta):
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
