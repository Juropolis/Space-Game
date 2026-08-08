extends Node

var touching_hurtboxes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for hurtbox in touching_hurtboxes:
		if is_instance_valid(hurtbox):
			hurtbox.hit_received()
	
	
func _on_area_entered(hurtbox):
	# Condition is a placeholder for things like hurtbox invincibility, friendly fire etc.
	if hurtbox.is_in_group("hurtboxes"):
		if hurtbox.has_method("hit_received"):
			if hurtbox.owner.team != owner.team:
				if hurtbox not in touching_hurtboxes:
					touching_hurtboxes.append(hurtbox)
				
func _on_area_exited(hurtbox):
	if hurtbox in touching_hurtboxes:
		touching_hurtboxes.erase(hurtbox)
	
