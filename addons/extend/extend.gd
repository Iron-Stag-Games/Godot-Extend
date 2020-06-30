tool
extends EditorPlugin

const applicants := [
	#"CollisionShape",
	#"CSGCombiner",
	#"MeshInstance",
	#"RigidBody",
	#"Spatial",
	"StaticBody",
]
const GizmoPlugin := preload("res://addons/extend/ExtendGizmoPlugin.gd")

var editor_settings := get_editor_interface().get_editor_settings()
var color: Color = editor_settings.get_setting("editors/3d_gizmos/gizmo_colors/shape")
var gizmo_plugins := []
var old_global_transform: Transform

onready var undo_redo := get_undo_redo()

func _init() -> void:
	for v in applicants:
		var gizmo_plugin := GizmoPlugin.new(v, color)
		gizmo_plugin.connect("start_drag", self, "start_drag")
		gizmo_plugin.connect("end_drag", self, "end_drag")
		gizmo_plugins.push_back(gizmo_plugin)

func _enter_tree() -> void:
	for gizmo_plugin in gizmo_plugins:
		add_spatial_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	for gizmo_plugin in gizmo_plugins:
		remove_spatial_gizmo_plugin(gizmo_plugin)

func start_drag(spatial: Spatial) -> void:
	old_global_transform = spatial.global_transform

func end_drag(spatial: Spatial) -> void:
	undo_redo.create_action("Translate Scale")
	undo_redo.add_do_property(spatial, "global_transform", spatial.global_transform)
	undo_redo.add_undo_property(spatial, "global_transform", old_global_transform)
	undo_redo.commit_action()
