extends Node

var touching_hurtboxes = []
var hit_hurtboxes = []
var attacker
var can_multi_hit = false
var hit_interval = 0.0
var hit_timer = 0.0
var damage = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_multi_hit(boolean):
	can_multi_hit = boolean

func set_attacker(character):
	attacker = character

func new_attack():
	hit_hurtboxes.clear()
	
func set_hit_interval(time):
	hit_interval = time
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for hurtbox in touching_hurtboxes:
		if is_instance_valid(hurtbox):
			
			if can_multi_hit:
				hurtbox.hit_received(damage)
				
			elif hurtbox not in hit_hurtboxes:
				hurtbox.hit_received(damage)
				hit_hurtboxes.append(hurtbox)
	
	
func _on_area_entered(hurtbox):
	# Condition is a placeholder for things like hurtbox invincibility, friendly fire etc.
	if hurtbox.is_in_group("hurtboxes"):
		if hurtbox.has_method("hit_received"):
			if hurtbox.owner.team != attacker.team:
				if hurtbox not in touching_hurtboxes:
					touching_hurtboxes.append(hurtbox)
				
func _on_area_exited(hurtbox):
	if hurtbox in touching_hurtboxes:
		touching_hurtboxes.erase(hurtbox)
	
