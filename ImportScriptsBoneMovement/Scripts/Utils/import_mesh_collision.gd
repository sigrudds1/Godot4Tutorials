# Problem -
#	In Godot 4 physics bodies do not follow the mesh when moved with a bone, but 
#		will move with a bone attachment.
# Requirements - 
#	Mesh names that ends with _NA will be ignored
# 
# Solution -
# 	IF mesh does not end with _NA:
#		Creates StaticBody3D and with CollisionsShape3D and attach it to the mesh
#		IF a the mesh is attched to a bone:
#			create a BoneAttachment3D and PhysicalBone3D as child and attaches
#				it to the Skeleton3D
#			Set the Bone Name properties of both BoneAttachment3D and PhysicalBone3D
#				to the found bone.
#			Move the CollisionsShape3D child from the StaticBody3D to be the child 
#				of PhysicalBone3D
# 
# Caveats - 
#	Does not flex the collsion shape to match vertices of less than 1.0 bone weight.
#	Only finds the first bone the mesh is assigned too.
#
# TODO - 
#	Check for fix to only finding the first bone, description suggests bones.


@tool
extends EditorScenePostImport


######### Virtual funcs #######################################################
func _post_import(scene: Node) -> Object:
	var n3d_scene = scene as Node3D
	
	if n3d_scene:
		var check_list: Array = n3d_scene.get_children()
		var l: int = check_list.size()
		while l > 0:
			var mi = check_list.pop_front()
			if mi is MeshInstance3D:
				if mi.get_name().rfind("_NA") > -1:
					print("continue:", mi)
					continue
#				else:
#					print("mesh name:", mi.get_name())
				
				# Less precise collision shape, less computation on collision detection
#				mi.create_multiple_convex_collisions()
				
				# Seems to have more precision, seems to have same vertice count
				mi.create_convex_collision()
				
				# More precise collision shape, computationally heavy
#				mi.create_trimesh_collision()
				
				var skel: Skeleton3D = mi.find_parent("Skeleton3D") as Skeleton3D
				if skel != null:
					var mdt = MeshDataTool.new()
					mdt.create_from_surface(mi.get_mesh(), 0)
					var bone_name: String = "~NAN~"
					for idx in mdt.get_vertex_count():
						var bones_i32a: PackedInt32Array = mdt.get_vertex_bones(idx)
						var bone_idx: int = bones_i32a.to_byte_array().decode_u32(0)
						var new_bone_name: String =  skel.get_bone_name(bone_idx)
#						print(new_bone_name)
						if bone_name == new_bone_name:
							continue
						
#						print(bone_name)
						
						bone_name = new_bone_name
						var name: String = bone_name + "_BA3D"
						var ba = skel.get_node_or_null(name)
						var pb = PhysicalBone3D
						if ba == null:
							ba = BoneAttachment3D.new()
	#						ba.set_name(mi.get_name() + "_BA3D")
							ba.set_name( bone_name + "_BA3D")
							ba.bone_name = bone_name
							ba.bone_idx = bone_idx
							skel.add_child(ba, false)
							ba.set_owner(n3d_scene)
							ba.set_transform(skel.get_bone_global_pose(bone_idx))
						
							pb = PhysicalBone3D.new()
							pb.bone_name = bone_name
							pb.set_name("PhysicalBone3D")
	#						pb.set_name(mi.get_name() + "_PB3D")
							ba.add_child(pb, false)
							pb.set_owner(n3d_scene)
							pb.set_body_offset(skel.get_bone_global_pose(bone_idx).affine_inverse())
						else:
							pb = ba.get_node_or_null("PhysicalBone3D")
						
						if pb == null:
							print("Physical bone not found")
							continue
							
						var sb = StaticBody3D
						for mi_ch in mi.get_children():
							if mi_ch is StaticBody3D:
								sb = mi_ch
							break
						if sb:
							var cs: CollisionShape3D = sb.get_node("CollisionShape3D") as CollisionShape3D
							if cs:
#								print("cs:", cs)
								cs.set_name(mi.get_name() + "_CS3D")
								sb.remove_child(cs)
								pb.add_child(cs)
								cs.set_owner(n3d_scene)
								mi.remove_child(sb)
						
#						print()
			
			elif mi != null:
				check_list.append_array(mi.get_children())
			l = check_list.size()
		
		var new_scene = PackedScene.new()
		var result = new_scene.pack(n3d_scene)
		if result == OK:
			DirAccess.remove_absolute("res://Scenes/" + n3d_scene.get_name() + ".tscn")
			var error = ResourceSaver.save(new_scene, 
					"res://Scenes/" + n3d_scene.get_name() + ".tscn")
			if error != OK:
				push_error("An error occurred while saving the scene to disk.")
			else:
				print("Saving to scene:", "res://Scenes/" + n3d_scene.get_name() + ".tscn")
		return n3d_scene
	else:
		print_debug("scene not found")
		return scene
