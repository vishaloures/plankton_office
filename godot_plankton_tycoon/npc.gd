extends CharacterBody3D

var SPEED = 2.0
var wander_timer = 0.0
var target_direction = Vector3.ZERO
var start_pos = Vector3.ZERO

func _ready():
	start_pos = global_position
	pick_new_direction()
	
	# Randomize form
	var forms = ["Crab", "Plankton", "Octopus", "Ray", "Squid", "Lobster", "SeaHorse", "Jellyfish"]
	setup_form(forms[randi() % forms.size()])

func setup_form(form_type: String):
	var mat = StandardMaterial3D.new()
	var b_mesh = BoxMesh.new()
	
	match form_type:
		"Crab":
			mat.albedo_color = Color(randf(), 0.38, 0.28)
			b_mesh.size = Vector3(1, 0.6, 0.8)
		"Plankton":
			mat.albedo_color = Color(0.2, randf(), 0.4)
			b_mesh.size = Vector3(0.5, 1.2, 0.5)
			if has_node("EyeL"):
				$EyeL.position = Vector3(0, 0.6, 0.26)
				$EyeL.scale = Vector3(1.5, 1.5, 1.5)
			if has_node("EyeR"): $EyeR.hide()
		"Octopus":
			mat.albedo_color = Color(0.6, 0.3, randf())
			b_mesh.size = Vector3(0.8, 1.0, 0.8)
		"Ray":
			mat.albedo_color = Color(0.3, 0.4, randf())
			b_mesh.size = Vector3(1.8, 0.2, 1.2)
		"Squid":
			mat.albedo_color = Color(0.9, randf(), 0.3)
			b_mesh.size = Vector3(0.6, 1.6, 0.6)
		"Lobster":
			mat.albedo_color = Color(randf(), 0.1, 0.1)
			b_mesh.size = Vector3(0.7, 0.5, 1.5)
		"SeaHorse":
			mat.albedo_color = Color(1.0, randf(), 0.2)
			b_mesh.size = Vector3(0.4, 1.8, 0.6)
		"Jellyfish":
			mat.albedo_color = Color(0.8, 0.6, 1.0, 0.6)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			b_mesh.size = Vector3(1.0, 0.8, 1.0)

	if has_node("Body"):
		$Body.mesh = b_mesh
		$Body.set_surface_override_material(0, mat)

func _physics_process(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		pick_new_direction()
		
	# Move
	velocity.x = target_direction.x * SPEED
	velocity.z = target_direction.z * SPEED
	
	if target_direction.length() > 0.1:
		var target_angle = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 5.0 * delta)
		
		# Wobble animation
		var wobble = sin(Time.get_ticks_msec() * 0.01) * 10.0
		if has_node("Body"):
			$Body.rotation_degrees.z = wobble
			if has_node("EyeL"): $EyeL.rotation_degrees.z = wobble
			if has_node("EyeR"): $EyeR.rotation_degrees.z = wobble
	else:
		if has_node("Body"):
			$Body.rotation_degrees.z = 0
			if has_node("EyeL"): $EyeL.rotation_degrees.z = 0
			if has_node("EyeR"): $EyeR.rotation_degrees.z = 0
			
	move_and_slide()
	
	# Keep them somewhat close to start position
	if global_position.distance_to(start_pos) > 20.0:
		target_direction = (start_pos - global_position).normalized()
		target_direction.y = 0

func pick_new_direction():
	wander_timer = randf_range(2.0, 5.0)
	if randf() > 0.5:
		target_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	else:
		target_direction = Vector3.ZERO # Stand still
