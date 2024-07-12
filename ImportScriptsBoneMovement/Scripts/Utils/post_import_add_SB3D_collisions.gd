@tool
extends EditorScenePostImport

const kLocationFolder: String = "res://Scenes/PostImport/"

######### Virtual funcs #######################################################
func _post_import(scene: Node) -> Object:
	var n3d_scene = scene as Node3D
	
	if n3d_scene:
		var check_list: Array = n3d_scene.get_children()
		while check_list.size() > 0:
			var mi = check_list.pop_front()
			if mi is MeshInstance3D:
				if mi.get_name().rfind("_NA") > -1:
					print("continue:", mi)
					continue
				
				# Less precise collision shape, less computation on collision detection
#				mi.create_multiple_convex_collisions()
				
				# Seems to have more precision, seems to have same vertice count
				mi.create_convex_collision()
				
				# More precise collision shape, computationally heavy
#				mi.create_trimesh_collision()
			elif mi != null:
				check_list.append_array(mi.get_children())
		
		print("n3d_scene:", n3d_scene.get_name())
#		n3d_scene.save("res://Scenes/" + n3d_scene.get_name() + ".tscn")
		var new_scene = PackedScene.new()
		var result = new_scene.pack(n3d_scene)
		print("result:", result)
		if result == OK:
			DirAccess.remove_absolute(kLocationFolder + n3d_scene.get_name() + ".tscn")
			var error = ResourceSaver.save(new_scene, 
					kLocationFolder + n3d_scene.get_name() + ".tscn")
			if error != OK:
				push_error("An error occurred while saving the scene to disk.")
		return n3d_scene
	else:
		print_debug("scene not found")
		return scene
