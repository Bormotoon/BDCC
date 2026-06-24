extends MeshInstance3D
class_name CurveRenderer

var anchorPath: String = ""
var anchorOffset := Vector3(0,0,0)
var originPath: String = "" 	#if unset, origin defaults to self
var originOffset := Vector3(0,0,0)

@export_range(0.001, 10) var width := 1.0
@export_range(0.1, 1) var flex := 0.5
@export_range(0.1, 10) var sag_static := 1.0
@export_range(0.1, 20) var expected_length := 5.0
@export_range(0.1, 20) var max_sagging_length := 2.5
@export_range(0.0, 1) var sag_from_length := 0.5

var anchor: Node3D
var origin: Node3D
var curve := Curve3D.new()
var immediate_mesh: ImmediateMesh

func _ready():
	immediate_mesh = ImmediateMesh.new()
	mesh = immediate_mesh
	curve.clear_points()
	curve.add_point(Vector3(0,0,0))
	curve.add_point(Vector3(-1,0,0))

func _process(_delta):
	if not visible or (not is_instance_valid(anchor) and anchorPath == ""):
		return

	if not is_instance_valid(anchor):
		anchor = get_node_or_null(NodePath(anchorPath))
		anchorPath = ""
	if not is_instance_valid(origin):
		if originPath != "":
			origin = get_node_or_null(NodePath(originPath))
			if origin == null:
				origin = self
		else:
			origin = self
		originPath = ""

	var origin_point = to_local(origin.to_global(originOffset))
	var anchor_point = to_local(anchor.to_global(anchorOffset))
	var mid_point = ((origin_point + anchor_point) * 0.5)
	var down_vec = (to_local(Vector3(0,-1,0)) - to_local(Vector3(0,0,0))).normalized()
	var unused_length = expected_length - anchor_point.length()
	if unused_length > max_sagging_length:
		unused_length = max_sagging_length
	if unused_length < 0:
		unused_length = 0
	var mid_point_sagged = mid_point + (down_vec * sag_static) + (down_vec * sag_from_length * unused_length)
	curve.set_point_position(0, origin_point)
	curve.set_point_out(0, mid_point_sagged * flex)
	curve.set_point_in(1, (mid_point_sagged - anchor_point) * flex)
	curve.set_point_position(1, anchor_point)

	var points = curve.tessellate()

	var camera_normal = Vector3(0,0,1)
	var topPoints: Array = []
	var botPoints: Array = []

	topPoints.append(points[0])
	botPoints.append(points[0])

	for i in range(1, points.size()):
		var prev_point = points[i - 1]
		var point = points[i]
		var diff = (point - prev_point)
		var tangent = diff.normalized()
		var curve_normal = camera_normal.cross(tangent).normalized()

		var prev_pointTop = prev_point + (curve_normal * (width * 0.5))
		var prev_pointBot = prev_point - (curve_normal * (width * 0.5))
		if i > 1:
			topPoints[i - 1] = (topPoints[i - 1] + prev_pointTop) * 0.5
			botPoints[i - 1] = (botPoints[i - 1] + prev_pointBot) * 0.5
		else:
			topPoints[i - 1] = prev_pointTop
			botPoints[i - 1] = prev_pointBot

		var pointTop = point + (curve_normal * (width * 0.5))
		var pointBot = point - (curve_normal * (width * 0.5))
		topPoints.append(pointTop)
		botPoints.append(pointBot)

	immediate_mesh.clear_surface()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	var dist = 0.0
	for i in range(1, points.size()):
		var diff = points[i] - points[i - 1]
		var length = diff.length()

		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(0, dist))
		immediate_mesh.surface_add_vertex(botPoints[i - 1])
		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(0, dist + length))
		immediate_mesh.surface_add_vertex(botPoints[i])
		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(1, dist + length))
		immediate_mesh.surface_add_vertex(topPoints[i])

		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(1, dist + length))
		immediate_mesh.surface_add_vertex(topPoints[i])
		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(1, dist))
		immediate_mesh.surface_add_vertex(topPoints[i - 1])
		immediate_mesh.surface_set_normal(camera_normal)
		immediate_mesh.surface_set_uv(Vector2(0, dist))
		immediate_mesh.surface_add_vertex(botPoints[i - 1])

		dist += length

	immediate_mesh.surface_end()
