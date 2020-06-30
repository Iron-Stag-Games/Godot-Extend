extends EditorSpatialGizmo

var spatial: Spatial
var gt: Transform
var scale: Vector3
var dragging := false

func redraw() -> void:
	clear()
	spatial = get_spatial_node()
	var lines = PoolVector3Array()
	lines.push_back(Vector3(0.5, 0.5, 0.5))
	lines.push_back(Vector3(-0.5, 0.5, 0.5))
	lines.push_back(Vector3(0.5, -0.5, 0.5))
	lines.push_back(Vector3(-0.5, -0.5, 0.5))
	lines.push_back(Vector3(0.5, 0.5, -0.5))
	lines.push_back(Vector3(-0.5, 0.5, -0.5))
	lines.push_back(Vector3(0.5, -0.5, -0.5))
	lines.push_back(Vector3(-0.5, -0.5, -0.5))
	
	lines.push_back(Vector3(0.5, 0.5, 0.5))
	lines.push_back(Vector3(0.5, -0.5, 0.5))
	lines.push_back(Vector3(-0.5, -0.5, 0.5))
	lines.push_back(Vector3(-0.5, 0.5, 0.5))
	lines.push_back(Vector3(0.5, 0.5, -0.5))
	lines.push_back(Vector3(0.5, -0.5, -0.5))
	lines.push_back(Vector3(-0.5, 0.5, -0.5))
	lines.push_back(Vector3(-0.5, -0.5, -0.5))
	
	lines.push_back(Vector3(0.5, 0.5, 0.5))
	lines.push_back(Vector3(0.5, 0.5, -0.5))
	lines.push_back(Vector3(-0.5, 0.5, 0.5))
	lines.push_back(Vector3(-0.5, 0.5, -0.5))
	lines.push_back(Vector3(0.5, -0.5, 0.5))
	lines.push_back(Vector3(0.5, -0.5, -0.5))
	lines.push_back(Vector3(-0.5, -0.5, 0.5))
	lines.push_back(Vector3(-0.5, -0.5, -0.5))
	
	var handles := PoolVector3Array()
	handles.push_back(Vector3(0.5, 0, 0))
	handles.push_back(Vector3(0, 0.5, 0))
	handles.push_back(Vector3(0, 0, 0.5))
	handles.push_back(Vector3(-0.5, 0, 0))
	handles.push_back(Vector3(0, -0.5, 0))
	handles.push_back(Vector3(0, 0, -0.5))
	add_lines(lines, get_plugin().get_material("lines", self))
	add_handles(handles, get_plugin().get_material("handles", self))

func set_handle(index: int, camera: Camera, point: Vector2) -> void:
	if not dragging:
		gt = spatial.global_transform
		scale = spatial.scale
		dragging = true
		get_plugin().emit_signal("start_drag", spatial)
	
	var gi: Transform
	
	match index:
		0:
			gi = gt.orthonormalized().translated(Vector3(-scale.x*0.5, 0, 0)).affine_inverse()
		1:
			gi = gt.orthonormalized().translated(Vector3(0, -scale.y*0.5, 0)).affine_inverse()
		2:
			gi = gt.orthonormalized().translated(Vector3(0, 0, -scale.z*0.5)).affine_inverse()
		3:
			gi = gt.orthonormalized().translated(Vector3(scale.x*0.5, 0, 0)).affine_inverse()
		4:
			gi = gt.orthonormalized().translated(Vector3(0, scale.y*0.5, 0)).affine_inverse()
		5:
			gi = gt.orthonormalized().translated(Vector3(0, 0, scale.z*0.5)).affine_inverse()
	
	var ray_from := camera.project_ray_origin(point)
	var ray_dir := camera.project_ray_normal(point)
	
	var sg := [ gi.xform(ray_from), gi.xform(ray_from + ray_dir * 16384) ]
	
	var axis: Vector3
	if index > 2:
		axis[index%3] = -1.0
	else:
		axis[index%3] = 1.0
	var arr := Geometry.get_closest_points_between_segments(Vector3.ZERO, axis * 4096, sg[0], sg[1]);
	var d := arr[1][index%3]
	if Input.is_key_pressed(KEY_CONTROL):
		d = stepify(d, 0.1)
	if index > 2:
		d = max(-d, 0.001)
	else:
		d = max(d, 0.001)
	
	match index:
		0:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(d*0.5 - 0.5*scale.x, 0, 0)).origin
		1:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(0, d*0.5 - 0.5*scale.y, 0)).origin
		2:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(0, 0, d*0.5 - 0.5*scale.z)).origin
		3:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(-d*0.5 + 0.5*scale.x, 0, 0)).origin
		4:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(0, -d*0.5 + 0.5*scale.y, 0)).origin
		5:
			spatial.global_transform.origin = gt.orthonormalized().translated(Vector3(0, 0, -d*0.5 + 0.5*scale.z)).origin
	
	if Input.is_key_pressed(KEY_SHIFT):
		match index%3:
			0:
				spatial.scale = scale*(d/scale.x)
			1:
				spatial.scale = scale*(d/scale.y)
			2:
				spatial.scale = scale*(d/scale.z)
	else:
		match index%3:
			0:
				spatial.scale = Vector3(d, scale.y, scale.z)
			1:
				spatial.scale = Vector3(scale.x, d, scale.z)
			2:
				spatial.scale = Vector3(scale.x, scale.y, d)

func commit_handle(index: int, restore, cancel := false) -> void:
	dragging = false
	gt = spatial.global_transform
	scale = spatial.scale
	get_plugin().emit_signal("end_drag", spatial)

func get_handle_name(index: int) -> String:
	return "Extend"

func get_handle_value(index: int) -> String:
	return String(spatial.scale - scale)
