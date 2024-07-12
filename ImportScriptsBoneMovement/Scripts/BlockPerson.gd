extends Node3D

var skel: Skeleton3D


var targets := Array()
var current_target: Node3D

#var _y_pivot_bone_idx: int
var _head_bone_idx: int

func _ready() -> void:
	skel = self.find_child("Skeleton3D")
	if skel != null:
		_head_bone_idx = skel.find_bone("Head")


var tm: float = 0.0
func _physics_process(p_delta) -> void:
	tm += p_delta
	if targets.size() > 0:
		current_target = targets[0]
	
	if current_target != null:
		if skel != null:
			if _head_bone_idx > -1:
				point_target_y_rot(current_target, _head_bone_idx)
#				point_target(current_target, _head_bone_idx)
	
	if tm > 1.0:
		tm -= 1.0


func point_target(p_target: Node3D, p_bone_idx: int) -> void:
	var target_pos = p_target.global_transform.origin
	var skel_transform: Transform3D = skel.get_global_transform()
	var bone_transform: Transform3D =  skel.get_bone_global_pose(p_bone_idx)

	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(target_pos).basis

	var dir_quat: Quaternion = dir_basis.get_rotation_quaternion()

	# Get the parent node's rotation and invert it
	var parent_rotation = self.get_parent().global_transform.basis.get_rotation_quaternion().inverse()
	dir_quat *= parent_rotation

	# Set the bone's global transform instead of just its pose rotation
	var bone_global_transform = skel_transform * bone_transform
	bone_global_transform.basis = dir_basis
	skel.set_bone_global_pose(p_bone_idx, bone_global_transform)

# Does not take into account the rotation and position of the scene
#func point_target(p_target: Node3D, p_bone_idx: int) -> void:
#	var target_pos = p_target.global_transform.origin
#	var skel_transform: Transform3D = skel.get_global_transform()
#	var bone_transform: Transform3D =  skel.get_bone_global_pose(p_bone_idx)
#
#	var from_transform: Transform3D = skel_transform * bone_transform
#	var dir_basis: Basis = from_transform.looking_at(target_pos).basis
#
#	var dir_quat: Quaternion = dir_basis.get_rotation_quaternion()
#	skel.set_bone_pose_rotation(p_bone_idx, dir_quat)


func point_target_xz_rot(p_target: Node3D, p_bone_idx: int) -> void:
	var target_pos = p_target.global_transform.origin
	var skel_transform: Transform3D = skel.get_global_transform()
	var bone_transform: Transform3D =  skel.get_bone_global_pose(p_bone_idx)
	
	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(target_pos).basis
	
	# xz rotation
	var x_rot = dir_basis.get_euler(1).x
	var z_rot = dir_basis.get_euler(1).z
	var xz_rotation = Quaternion(Vector3(1, 0, 0), x_rot) * Quaternion(Vector3(0, 0, 1), z_rot)
	skel.set_bone_pose_rotation(p_bone_idx, xz_rotation)
# Note that for the xz rotation, we first get the rotation angle around the x axis,
#	then the rotation angle around the z axis, and then combine them into a single
#	xz_rotation quaternion using quaternion multiplication.


func point_target_y_rot(p_target: Node3D, p_bone_idx: int) -> void:
	var target_pos = p_target.global_transform.origin
	var skel_transform: Transform3D = skel.get_global_transform()
	var bone_transform: Transform3D =  skel.get_bone_global_pose(p_bone_idx)
	
	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(target_pos).basis
	
	var y_rot = dir_basis.get_euler().y - skel_transform.basis.get_euler().y
	var y_pivot_rotation = Quaternion(Vector3.UP, y_rot)
	skel.set_bone_pose_rotation(p_bone_idx, y_pivot_rotation)


func _on_detection_area_3d_body_entered(p_body):
	var body_owner = p_body.get_owner()
	if body_owner.is_in_group("Enemies"):
		if targets.find(p_body) < 0:
			targets.push_back(body_owner)


func _on_detection_area_3d_body_exited(p_body):
	var body_owner = p_body.get_owner()
	var idx: int = targets.find(body_owner)
	if  idx >= 0:
		targets.remove_at(idx)


