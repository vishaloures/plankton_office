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

func _ready():
	kanban_ui.hide()
	task_progress_bar.hide()
	
	# Настраиваем текст навыка
	match Global.super_skill:
		"Fart": super_label.text = "ГАЗЫ:"
		"Alcoholic": super_label.text = "СОНЛИВОСТЬ:"
		"Sarcasm": super_label.text = "САРКАЗМ:"

@onready var desk = $Desk
@onready var cooler = $Cooler
@onready var fridge = $Fridge
@onready var window_mesh = $Window

@onready var btn_kanban = $UI/MarginContainer/VBoxContainer/KanbanBtn
@onready var btn_eat = $UI/MarginContainer/VBoxContainer/ControlButtons/Eat
@onready var btn_drink = $UI/MarginContainer/VBoxContainer/ControlButtons/Drink
@onready var btn_vent = $UI/MarginContainer/VBoxContainer/ControlButtons/Vent

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
