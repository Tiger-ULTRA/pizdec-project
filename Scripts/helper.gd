extends Node3D

func get_mouse_world_position():
	var mouse_pos = get_viewport().get_mouse_position() # 2D position
	var camera = get_viewport().get_camera_3d()
	
	# Define ray start (camera) and end (far away in direction of mouse)
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 2000 # 2000 is ray length
	
	# Access the 3D physics world state
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	
	var result = space_state.intersect_ray(query) # Check for intersection
	
	if result:
		return result.position # The Vector3 world position
	return null
