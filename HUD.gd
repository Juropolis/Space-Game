extends CanvasLayer

@onready var health_sprite = $AnimatedSprite2D

func update_health(health):
	match health:
		3:
			health_sprite.animation = "3_hearts"
		2:
			health_sprite.animation = "2_hearts"
		1:
			health_sprite.animation = "1_hearts"
		0:
			health_sprite.animation = "0_hearts"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
