extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func _on_area_entered(hurtbox):
	# Condition is a placeholder for things like hurtbox invincibility, friendly fire etc.
	if hurtbox.is_in_group("hurtboxes"):
		if hurtbox.has_method("hit_received"):
			if hurtbox.owner.team != owner.team:
				hurtbox.hit_received()
	
