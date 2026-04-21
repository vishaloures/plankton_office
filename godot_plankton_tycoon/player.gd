extends CharacterBody3D

signal task_completed(score_gain)

const SPEED = 5.0

# Шкалы состояния
var hunger: float = 100.0
var burnout: float = 0.0
var dushnota: float = 0.0

var is_working: bool = false
var current_task_name: String = ""
var task_progress: float = 0.0
var score: int = 0

var work_speed: float = 15.0
var burnout_rate: float = 6.0
var hunger_rate: float = 3.0
var dushnota_rate: float = 4.0

var super_skill_progress: float = 0.0
var super_skill_ready: bool = false

@onready var body_mesh = $Body
@onready var eye_l = $EyeL
@onready var eye_r = $EyeR
@onready var fart_particles = $FartParticles
@onready var event_label = $EventLabel

func show_event_text(text: String, duration: float = 2.0):
	if event_label:
		event_label.text = text
		event_label.modulate = Color(1, 1, 1, 1) # Сброс прозрачности
		
		# Создаем твин для анимации исчезновения (плавное растворение)
		var tween = create_tween()
		tween.tween_interval(duration * 0.7) # Текст висит полностью видимым 70% времени
		tween.tween_property(event_label, "modulate:a", 0.0, duration * 0.3) # И плавно растворяется
		tween.tween_callback(func(): event_label.text = "")

func _ready():
	if Global.character_form == "Plankton":
		setup_plankton()

	if Global.basic_skill == "Programmer":
		work_speed = 25.0
		burnout_rate = 10.0
	elif Global.basic_skill == "Manager":
		work_speed = 8.0
		burnout_rate = 3.0
		hunger_rate = 1.0
	elif Global.basic_skill == "Designer":
		work_speed = 12.0
		dushnota_rate = 8.0

func setup_plankton():
	var plankton_mat = StandardMaterial3D.new()
	plankton_mat.albedo_color = Color(0.2, 0.8, 0.4)
	var plankton_mesh = BoxMesh.new()
	plankton_mesh.size = Vector3(0.5, 1.2, 0.5)
	body_mesh.mesh = plankton_mesh
	body_mesh.set_surface_override_material(0, plankton_mat)
	eye_l.position = Vector3(0, 0.6, 0.26)
	eye_l.scale = Vector3(1.5, 1.5, 1.5)
	eye_r.hide()

func _physics_process(delta: float):
	if not super_skill_ready:
		super_skill_progress += 8.0 * delta # Заполняется со временем
		if super_skill_progress >= 100.0:
			super_skill_progress = 100.0
			super_skill_ready = true
			is_working = false # Бросаем работу, когда припекло!

	if is_working and current_task_name != "":
		work_on_task(delta)
	elif not super_skill_ready:
		hunger -= 0.5 * delta
		burnout = max(0, burnout - 5.0 * delta)
	
	hunger = clamp(hunger, 0, 100)
	burnout = clamp(burnout, 0, 100)
	dushnota = clamp(dushnota, 0, 100)
	
	if burnout >= 99 or hunger <= 1 or dushnota >= 99:
		is_working = false
	
	# Движение (только если не работаем и не в приступе навыка)
	if not is_working and not super_skill_ready:
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		var cam_basis = get_viewport().get_camera_3d().global_transform.basis
		var direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y))
		direction.y = 0
		direction = direction.normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			var target_angle = atan2(velocity.x, velocity.z)
			rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
		
	update_visuals()

func work_on_task(delta):
	burnout += burnout_rate * delta
	hunger -= hunger_rate * delta
	dushnota += dushnota_rate * delta
	
	task_progress += work_speed * delta
	
	if task_progress >= 100.0:
		complete_task()

# Клик мышкой по самому персонажу
func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if super_skill_ready:
			activate_super_skill()

func activate_super_skill():
	super_skill_ready = false
	super_skill_progress = 0.0
	
	if Global.super_skill == "Fart":
		show_event_text("ПУУУК! Газовая атака!")
		dushnota += 50.0
		if fart_particles:
			fart_particles.restart()
			fart_particles.emitting = true
	elif Global.super_skill == "Alcoholic":
		show_event_text("ХРРРР... Уснул.")
		burnout += 40.0
	elif Global.super_skill == "Sarcasm":
		show_event_text("Токсичный комментарий на ревью.")
		burnout += 20.0
		dushnota += 20.0

func complete_task():
	score += 100
	task_completed.emit(100)
	current_task_name = ""
	task_progress = 0.0
	is_working = false
	show_event_text("Задача выполнена!")

func update_visuals():
	var wobble = 0.0
	if super_skill_ready:
		# Жесткая тряска!
		wobble = sin(Time.get_ticks_msec() * 0.1) * 15.0
		body_mesh.rotation_degrees.z = wobble
		body_mesh.rotation_degrees.x = sin(Time.get_ticks_msec() * 0.15) * 10.0
		eye_l.rotation_degrees.z = wobble
		eye_r.rotation_degrees.z = wobble
		position.y = 0.5 + sin(Time.get_ticks_msec() * 0.1) * 0.2
	else:
		body_mesh.rotation_degrees.x = 0
		if is_working:
			wobble = sin(Time.get_ticks_msec() * 0.05) * 5.0
			body_mesh.rotation_degrees.z = wobble
			eye_l.rotation_degrees.z = wobble
			eye_r.rotation_degrees.z = wobble
			position.y = 0.5
		elif velocity.length() > 0.1:
			wobble = sin(Time.get_ticks_msec() * 0.02) * 8.0
			body_mesh.rotation_degrees.z = wobble
			eye_l.rotation_degrees.z = wobble
			eye_r.rotation_degrees.z = wobble
			position.y = 0.5 + sin(Time.get_ticks_msec() * 0.01) * 0.1
		else:
			body_mesh.rotation_degrees.z = 0
			eye_l.rotation_degrees.z = 0
			eye_r.rotation_degrees.z = 0
			position.y = 0.5

func start_task(task_name: String):
	current_task_name = task_name
	task_progress = 0.0
	is_working = true
	rotation.y = atan2(0 - global_position.x, 0 - global_position.z)

func eat():
	hunger = 100.0
	show_event_text("Ням-ням!")

func drink():
	burnout = max(0, burnout - 50.0)
	show_event_text("Глоток кофе...")

func vent():
	dushnota = 0.0
	show_event_text("Свежий воздух!")
