extends Node
const DAMAGE = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func _on_area_entered(hurtbox):
	if hurtbox.has_method("take_damage"):
		hurtbox.take_damage(DAMAGE)
	
