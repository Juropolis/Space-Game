extends Node

var hurtbox_state = "normal"
var invincibility_timer = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match hurtbox_state:
		"invincible":
			handle_invincibility(delta)


func hit_received():
	if hurtbox_state != "invincible":
		get_parent().hit_received()
	
func handle_invincibility(delta):
	invincibility_timer -= delta
	if invincibility_timer <= 0:
		hurtbox_state = "normal"
	
func make_invincible(time: float):
	invincibility_timer = time
	hurtbox_state = "invincible"
