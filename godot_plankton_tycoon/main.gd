extends Node3D

@onready var player = $Player
@onready var hunger_bar = $UI/MarginContainer/VBoxContainer/Hunger/ProgressBar
@onready var burnout_bar = $UI/MarginContainer/VBoxContainer/Burnout/ProgressBar
@onready var dushnota_bar = $UI/MarginContainer/VBoxContainer/Dushnota/ProgressBar
@onready var status_label = $UI/MarginContainer/VBoxContainer/StatusLabel
@onready var kanban_ui = $UI/KanbanBoard
@onready var task_progress_bar = $UI/MarginContainer/VBoxContainer/TaskProgress
@onready var score_label = $UI/MarginContainer/VBoxContainer/ScoreLabel

@onready var super_bar = $UI/MarginContainer/VBoxContainer/SuperSkill/ProgressBar
@onready var super_label = $UI/MarginContainer/VBoxContainer/SuperSkill/Label

var npc_scene = preload("res://npc.tscn")

func _ready():
	kanban_ui.hide()
	task_progress_bar.hide()
	
	# Настраиваем текст навыка
	match Global.super_skill:
		"Fart": super_label.text = "ГАЗЫ:"
		"Alcoholic": super_label.text = "СОНЛИВОСТЬ:"
		"Sarcasm": super_label.text = "САРКАЗМ:"
		
	# Спавним других NPC и рабочие места
	for i in range(15):
		var new_npc = npc_scene.instantiate()
		new_npc.position = Vector3(randf_range(-20, 20), 0.5, randf_range(-20, 20))
		add_child(new_npc)
		
		var new_desk = desk.duplicate()
		new_desk.position = Vector3(randf_range(-20, 20), 0.4, randf_range(-20, 20))
		new_desk.rotation_degrees.y = randf_range(0, 360)
		add_child(new_desk)

@onready var desk = $Desk
@onready var cooler = $Cooler
@onready var fridge = $Fridge
@onready var window_mesh = $Window

@onready var btn_kanban = $UI/MarginContainer/VBoxContainer/KanbanBtn
@onready var btn_eat = $UI/MarginContainer/VBoxContainer/ControlButtons/Eat
@onready var btn_drink = $UI/MarginContainer/VBoxContainer/ControlButtons/Drink
@onready var btn_vent = $UI/MarginContainer/VBoxContainer/ControlButtons/Vent

@onready var camera = $Camera3D
var dragging_camera = false
var last_mouse_pos = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = clamp(camera.size - 1.0, 4.0, 30.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = clamp(camera.size + 1.0, 4.0, 30.0)
		
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging_camera = true
				last_mouse_pos = event.position
			else:
				dragging_camera = false
	elif event is InputEventMagnifyGesture:
		camera.size = clamp(camera.size / event.factor, 4.0, 30.0)
	elif event is InputEventMouseMotion and dragging_camera:
		var delta_pos = event.position - last_mouse_pos
		last_mouse_pos = event.position
		
		var right = camera.global_transform.basis.x
		right.y = 0
		right = right.normalized()
		
		var forward = -camera.global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		
		camera.global_position -= (right * delta_pos.x + forward * delta_pos.y) * 0.02

func _process(_delta):
	hunger_bar.value = player.hunger
	burnout_bar.value = player.burnout
	dushnota_bar.value = player.dushnota
	score_label.text = "ОЧКИ: " + str(player.score)
	
	# Обновляем прогресс навыка
	super_bar.value = player.super_skill_progress
	if player.super_skill_ready:
		super_bar.modulate = Color.YELLOW
	else:
		super_bar.modulate = Color.WHITE
	
	if player.current_task_name != "":
		task_progress_bar.show()
		task_progress_bar.value = player.task_progress
		status_label.text = Global.character_name + " - РАБОТАЕТ: " + player.current_task_name
		status_label.modulate = Color.CYAN
	elif player.super_skill_ready:
		status_label.text = "ЖМИ НА ПЕРСОНАЖА!"
		status_label.modulate = Color.ORANGE
	elif player.is_working == false and (player.burnout >= 99 or player.hunger <= 1 or player.dushnota >= 99):
		task_progress_bar.hide()
		status_label.text = Global.character_name + " - СТАТУС: В ПАНИКЕ!"
		status_label.modulate = Color.RED
	else:
		task_progress_bar.hide()
		status_label.text = Global.character_name + " - СТАТУС: ОЖИДАНИЕ ЗАДАЧИ"
		status_label.modulate = Color.WHITE

	# Дистанции для взаимодействия
	var dist_desk = player.global_position.distance_to(desk.global_position)
	btn_kanban.disabled = dist_desk > 3.0

	var dist_fridge = player.global_position.distance_to(fridge.global_position)
	btn_eat.disabled = dist_fridge > 3.0

	var dist_cooler = player.global_position.distance_to(cooler.global_position)
	btn_drink.disabled = dist_cooler > 3.0

	var dist_window = player.global_position.distance_to(window_mesh.global_position)
	btn_vent.disabled = dist_window > 3.0

# --- Кнопки интерфейса ---
func _on_eat_pressed():
	player.eat()

func _on_drink_pressed():
	player.drink()

func _on_vent_pressed():
	player.vent()

# --- Логика Канбана ---
func _on_open_kanban_pressed():
	kanban_ui.show()

func _on_task_selected(task_name: String):
	player.start_task(task_name)
	kanban_ui.hide()

func _on_close_kanban_pressed():
	kanban_ui.hide()
