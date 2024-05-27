@tool
extends EditorScenePostImport

@export var material_search_path = "res://assets/materials"
@export var fallback_mat_path = "res://assets/materials/dev/missing.tres"

var material_path

func _post_import(scene):
	iterate(scene)
	print("Map imported successfully!")
	return scene
	
func iterate(node):
	if node != null:
		if node is MeshInstance3D:
			node.use_in_baked_light = true
			var original_mesh = node.mesh
			for surface_index in original_mesh.get_surface_count():
				var material_name = original_mesh.get("surface_" + str(surface_index) + "/name") # Get path for material of surface
				material_name = material_name.replace(".vmat", "")
				material_path = fallback_mat_path
				get_material_path(material_search_path, material_name)
				if material_path == fallback_mat_path:
					push_error("Error, material not found, assigning fallback material!: " + material_name)
				
				var st = SurfaceTool.new()
				st.create_from(original_mesh, surface_index)
				var mesh = st.commit()
				var shape = CollisionShape3D.new()
				shape.shape = mesh.create_trimesh_shape()
				var body = StaticBody3D.new()
				body.add_child(shape, true)
				node.add_child(body, true)
				
				body.owner = node.owner
				shape.owner = node.owner
				
				if load(material_path):
					node.mesh.surface_set_material(surface_index, load(material_path)) #TEMP 
					if node.mesh.surface_get_material(surface_index).has_meta("MaterialProperties"):
						var mat_prop = node.mesh.surface_get_material(surface_index).get_meta("MaterialProperties")
						body.physics_material_override = mat_prop
						if mat_prop.DISABLE_COLLISIONS:
							body.queue_free()
					else:
						body.physics_material_override = load(fallback_mat_path).get_meta("MaterialProperties")
				else: #If the material was not found
					push_error("DEFAULT MATERIAL NOT FOUND! Should be in " + fallback_mat_path)
			
			#var body = StaticBody3D.new()
			#var collision_shape = node.mesh.create_convex_shape(true, true)
			#var shape = CollisionShape3D.new()
			#shape.shape = collision_shape
			#body.add_child(shape, true)
			#node.add_child(body, true)
			#body.set_collision_layer_value(1, true)
			#body.set_collision_mask_value(1, true)
			#body.owner = node.owner
			#shape.owner = node.owner
		for child in node.get_children():
			iterate(child)
	
func get_material_path(dir_path: String, file: String):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file_path = dir_path + "/" + file_name
			if dir.current_is_dir():
				get_material_path(file_path, file)
			else:
				if file_name == (file + ".tres"):
					material_path = file_path
			file_name = dir.get_next()
