@tool
extends StaticBody2D

@onready var path: Path2D = get_node("Path2D")
@onready var visual_polygon: Polygon2D = get_node("Polygon2D")
@onready var collision_polygon: CollisionPolygon2D = get_node("CollisionPolygon2D")

@export_range(0.1, 100, 0.1) var thickness: float = 30.0:
	set(value):
		thickness = value
		update_platform()
		

func _ready():
	if path and path.curve:
		if not path.curve.changed.is_connected(_on_curve_changed):
			path.curve.changed.connect(_on_curve_changed)
	call_deferred("update_platform")

func _on_curve_changed():
	call_deferred("update_platform")

func update_platform():
	if not is_inside_tree() or not path or not visual_polygon or not collision_polygon:
		return
		
	var curve: Curve2D = path.curve
	if not curve or curve.get_baked_points().size() < 2:
		visual_polygon.polygon = PackedVector2Array()
		collision_polygon.polygon = PackedVector2Array()
		return
		
	var top_points: PackedVector2Array = curve.get_baked_points()
	
	var planet_center = Vector2.ZERO
	if get_parent() and get_parent().is_inside_tree():
		planet_center = to_local(get_parent().global_position)
	
	var visual_surface: PackedVector2Array = []
	var extruded_floor: PackedVector2Array = []
	
	for i in range(top_points.size()):
		var point = top_points[i]
		visual_surface.append(point)
		
		var distance_to_center = point.distance_to(planet_center)
		var direction_to_center = (planet_center - point).normalized()
		var safe_thickness = min(thickness, distance_to_center * 0.5)
		
		var bottom_point = point - (direction_to_center * safe_thickness)
		extruded_floor.append(bottom_point)
		
	extruded_floor.reverse()
	
	var final_polygon: PackedVector2Array = []
	final_polygon.append_array(visual_surface)
	final_polygon.append_array(extruded_floor)
	
	collision_polygon.polygon = final_polygon
	visual_polygon.polygon = final_polygon
