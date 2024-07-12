@tool
extends Node

@export var scene: PackedScene

@export var update: bool:
	set(_update):
		update = false
		if scene == null:
			return
		add_detection_area()


func add_detection_area() -> void:
	var n3d: Node3D = scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node3D
	self.add_child(n3d)
	
	print("n3d:", n3d)
	if n3d:
		if n3d.get_node_or_null("DetectionArea3D") != null:
			print("Detection area already added")
			return
		
		var new_a3d: Area3D = Area3D.new()
		new_a3d.set_name("DetectionArea3D")
		n3d.add_child(new_a3d)
		new_a3d.set_owner(n3d)
		
		var cs3d: CollisionShape3D = CollisionShape3D.new()
		cs3d.set_name("DetectionSphere")
		new_a3d.add_child(cs3d)
		cs3d.set_owner(n3d)
		
		var ss3d: SphereShape3D = SphereShape3D.new()
		ss3d.set_name("SphereShape3D")
		ss3d.set_local_to_scene(true)
		cs3d.set_shape(ss3d)
		
		# TODO - Check if script is attached or create script export var to attach
		# Todo - add signals to top class parent (Unit) "res://Scripts/Classes/cUnit.gd"
		# 	but I believe you have to get it thru get_parent ... to the top since they are instantiated
		
		
		var path: String = scene.resource_path
		# Current workaround is to rename tscn possible fix...
		# 	scene.unreference() # to overwrite tscn?
		path = path.get_basename() + "_DA." + path.get_extension()
		print("path:", path)
		var new_scene = PackedScene.new()
		var result = new_scene.pack(n3d)
		print("result:", result)
		if result == OK:
			DirAccess.remove_absolute(path)
			var error = ResourceSaver.save(new_scene, path)
			if error != OK:
				push_error("An error occurred while saving the scene to disk.")
			else:
				print("Added detection area")
			
		
