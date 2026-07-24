@tool
extends StaticBody2D

var visual_polygon: Polygon2D:
	get:
		return get_node_or_null("Polygon2D")

var collision_polygon: CollisionPolygon2D:
	get:
		return get_node_or_null("CollisionPolygon2D")

@export_range(5.0, 500.0, 1.0) var distance_from_planet: float = 300.0: # Floating distance from center
	set(value):
		distance_from_planet = value
		update_platform()
		queue_redraw()

@export_range(0.0, 360.0, 0.5) var start_angle: float = 0.0: # Where the platform begins on a 360° wheel
	set(value):
		start_angle = value
		update_platform()
		queue_redraw()

@export_range(1.0, 360.0, 0.5) var arc_length: float = 20.0:
	set(value):
		arc_length = value
		update_platform()
		queue_redraw()
		
@export_range(10, 500, 1) var subdivisions: int = 100:
	set(value):
		subdivisions = value
		update_platform()
		queue_redraw()
		
@export_range(0.1, 100, 0.1) var thickness: float = 30.0:
	set(value):
		thickness = value
		update_platform()
		queue_redraw()
		

func update_platform():
	
	# 1. Strict node initialization guard check
	if not is_inside_tree():
		return
	if visual_polygon == null or collision_polygon == null:
		return
		
	# Planet must be at 0,0 in its own scene
	var planet_centre = Vector2.ZERO
	
	# The distance to the planet from where you clicked
	
	
	# The angle that you clicked at
	var start_angle_rad = deg_to_rad(start_angle - 90)
	
	# Angle between each point
	var angle_step = deg_to_rad(arc_length) / float(subdivisions)
	
	var visual_surface: PackedVector2Array = []
	var extruded_floor: PackedVector2Array = []
	
	for i in range(0, subdivisions + 1):
		var current_angle = start_angle_rad + (i * angle_step)
		
		# Trace a circle radius based on distance slider
		var x = planet_centre.x + cos(current_angle) * distance_from_planet
		var y = planet_centre.y + sin(current_angle) * distance_from_planet
		var point = Vector2(x, y)
		
		visual_surface.append(point)
		
		var direction_to_centre = (planet_centre - point).normalized()
		var safe_thickness = min(thickness, distance_from_planet * 0.8)
		var bottom_point = point - (direction_to_centre * safe_thickness)
		
		extruded_floor.append(bottom_point)	
		
	extruded_floor.reverse()
	var final_polygon: PackedVector2Array = []
	final_polygon.append_array(visual_surface)
	final_polygon.append_array(extruded_floor)

	collision_polygon.polygon = final_polygon
	visual_polygon.polygon = final_polygon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_platform()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
