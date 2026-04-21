extends CharacterBody3D

var SPEED = 2.0
var wander_timer = 0.0
var target_direction = Vector3.ZERO
var start_pos = Vector3.ZERO

func _ready():
	start_pos = global_position
	pick_new_direction()
	
	# Randomize color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(randf(), randf(), randf(), 1)
	if has_node("Body"):
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
