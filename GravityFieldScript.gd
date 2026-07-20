extends Area2D

@export var gravity_strength: float = 1200
@onready var collision_shape = $CollisionShape2D

var gravity_radius: float:
	get:
		return collision_shape.shape.radius * collision_shape.global_scale.x

func get_gravity_strength() -> float:
	return gravity_strength

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
