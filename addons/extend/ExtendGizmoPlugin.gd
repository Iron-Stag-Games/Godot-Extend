extends EditorSpatialGizmoPlugin

const Gizmo := preload("res://addons/extend/ExtendGizmo.gd")

var gizmo_class_name: String

signal start_drag
signal end_drag

func _init(gizmo_class_name2: String, color: Color) -> void:
	gizmo_class_name = gizmo_class_name2
	create_material("lines", color)
	create_handle_material("handles")

func create_gizmo(spatial: Spatial) -> EditorSpatialGizmo:
	if spatial.get_class() == gizmo_class_name:
		return Gizmo.new()
	else:
		return null

func get_name() -> String:
	return "﻿Extend:" + gizmo_class_name
