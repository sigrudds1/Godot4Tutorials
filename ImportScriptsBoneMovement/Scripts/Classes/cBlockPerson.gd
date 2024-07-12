class_name BlockPerson extends Node3D

var skel: Skeleton3D
var detect_bubble: CollisionShape3D

var targets := Array()
var current_target: Node3D
var sensor_range: float = 25.0

var _head_bone_idx: int

func _ready() -> void:
	skel = self.find_child("Skeleton3D")
	if skel != null:
		_head_bone_idx = skel.find_bone("Head")
	
	detect_bubble = self.find_child("DetectionSphere")
	if is_instance_valid(detect_bubble):
		var shape: Shape3D = detect_bubble.get_shape()
		if shape is SphereShape3D:
			shape.set_radius(sensor_range)


var tm: float = 0.0
func _physics_process(p_delta) -> void:
	tm += p_delta
	if targets.size() > 0:
		current_target = targets[0]
	else:
		current_target = null
	
	if current_target != null:
		var target_pos: Vector3 = current_target.global_transform.origin
		if skel != null:
			if _head_bone_idx > -1:
				point_target(target_pos, skel, _head_bone_idx)
#				point_target_y_rot(current_target, _head_bone_idx)
	
	if tm > 1.0:
		tm -= 1.0



# Working
func point_target(p_target_pos: Vector3, p_skel: Skeleton3D, p_bone_idx: int) -> void:
	var skel_transform: Transform3D = p_skel.get_global_transform()
	var bone_transform: Transform3D =  p_skel.get_bone_global_pose(p_bone_idx)
	
	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(p_target_pos, Vector3.UP).basis
	
	var y_rot = dir_basis.get_euler().y - skel_transform.basis.get_euler().y
	var x_rot = dir_basis.get_euler().x
	var z_rot = dir_basis.get_euler().z
	var pivot_rotation = Quaternion(Vector3.UP, y_rot) * Quaternion(Vector3.RIGHT, x_rot) * \
			Quaternion(Vector3.BACK, z_rot)
	
	p_skel.set_bone_pose_rotation(p_bone_idx, pivot_rotation)
	
#	var bone_global_transform: Transform = muzzle_bone_att.get_global_transform()
#	var opp = bone_global_transform.origin.y - trgt_pos.y
#	var hyp = trgt_pos.distance_to(bone_global_transform.origin)
#	var angle = asin(opp/hyp)
#	var bone_transform = transform_offset[tier - 1]
#	bone_transform = bone_transform.rotated(Vector3(0,0,1), angle_offset[tier - 1] + angle)
#	skel.set_bone_pose(muzzle_bone, bone_transform)

# Working???
func point_target_x(p_target_pos: Vector3, p_skel: Skeleton3D, p_bone_idx: int) -> void:
	var skel_transform: Transform3D = p_skel.get_global_transform()
	var bone_transform: Transform3D = p_skel.get_bone_global_pose(p_bone_idx)
	
	var bone_glb_xform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = bone_glb_xform.looking_at(p_target_pos).basis
	
	# xz rotation
	var x_rot = dir_basis.get_euler(1).x
#	var z_rot = dir_basis.get_euler(1).z
#	var xz_rotation = Quaternion(Vector3(1, 0, 0), x_rot) * Quaternion(Vector3(0, 0, 1), z_rot)
	p_skel.set_bone_pose_rotation(p_bone_idx, Quaternion(Vector3(1, 0, 0), x_rot))


# Working???
func point_target_xz_rot(p_target_pos: Vector3, p_skel: Skeleton3D, p_bone_idx: int) -> void:
	var skel_transform: Transform3D = p_skel.get_global_transform()
	var bone_transform: Transform3D = p_skel.get_bone_global_pose(p_bone_idx)
	
	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(p_target_pos).basis
	
	# xz rotation
	var x_rot = dir_basis.get_euler(1).x
	var z_rot = dir_basis.get_euler(1).z
	var xz_rotation = Quaternion(Vector3.RIGHT, x_rot) * Quaternion(Vector3.BACK, z_rot)
	p_skel.set_bone_pose_rotation(p_bone_idx, xz_rotation)


# Working
func point_target_y_rot(p_target_pos: Vector3, p_skel: Skeleton3D, p_bone_idx: int) -> void:
	var skel_transform: Transform3D = p_skel.get_global_transform()
	var bone_transform: Transform3D = p_skel.get_bone_global_pose(p_bone_idx)
	
	var from_transform: Transform3D = skel_transform * bone_transform
	var dir_basis: Basis = from_transform.looking_at(p_target_pos).basis
	
	var y_rot = dir_basis.get_euler().y - skel_transform.basis.get_euler().y
	var y_pivot_rotation = Quaternion(Vector3.UP, y_rot)
	p_skel.set_bone_pose_rotation(p_bone_idx, y_pivot_rotation)


func _on_detection_area_3d_body_entered(p_body):
	print("_on_detection_area_3d_body_entered", p_body)
	var body_owner = p_body.get_owner()
	if body_owner.is_in_group("Enemies"):
		if targets.find(p_body) < 0:
			targets.push_back(body_owner)


func _on_detection_area_3d_body_exited(p_body):
	print("_on_detection_area_3d_body_exited", p_body)
	var body_owner = p_body.get_owner()
	var idx: int = targets.find(body_owner)
	if  idx >= 0:
		targets.remove_at(idx)
