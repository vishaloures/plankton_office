extends Control

@onready var form_option = $VBoxContainer/FormBox/FormOption
@onready var basic_option = $VBoxContainer/BasicBox/BasicOption
@onready var super_option = $VBoxContainer/SuperBox/SuperOption
@onready var name_input = $VBoxContainer/NameBox/NameInput

func _ready():
	form_option.clear()
	form_option.add_item("Краб")
	form_option.add_item("Планктон")
	form_option.add_item("Осьминог")
	form_option.add_item("Скат")
	form_option.add_item("Кальмар")
	form_option.add_item("Омар")
	form_option.add_item("Морской конек")
	form_option.add_item("Медуза")
	
	basic_option.add_item("Программист (Быстрый код, быстрое выгорание)")
	basic_option.add_item("Менеджер (Медленно работает, мало ест)")
	basic_option.add_item("Дизайнер (Средне работает, постоянно душно)")
	
	super_option.add_item("Пукун (Регулярные газовые атаки)")
	super_option.add_item("Сонный алкоголик (Внезапные приступы усталости)")
	super_option.add_item("Токсичный сарказм (Быстро выгорает сам и бесит всех)")
	
	generate_funny_name()

func generate_funny_name():
	var first_names = ["Краб", "Планктон", "Осьминог", "Скат", "Кальмар", "Омар", "Морской конек", "Медуз"]
	var last_names = ["Геннадий", "Валерий", "Олег", "Иннокентий", "Аркадий", "Борис", "Степан", "Эдуард"]
	name_input.text = first_names[randi() % first_names.size()] + " " + last_names[randi() % last_names.size()]

func _on_start_pressed():
	var forms = ["Crab", "Plankton", "Octopus", "Ray", "Squid", "Lobster", "SeaHorse", "Jellyfish"]
	Global.character_form = forms[form_option.selected]
	
	match basic_option.selected:
		0: Global.basic_skill = "Programmer"
		1: Global.basic_skill = "Manager"
		2: Global.basic_skill = "Designer"
		
	match super_option.selected:
		0: Global.super_skill = "Fart"
		1: Global.super_skill = "Alcoholic"
		2: Global.super_skill = "Sarcasm"
		
	Global.character_name = name_input.text if name_input.text.strip_edges() != "" else "Аноним"
	
	get_tree().change_scene_to_file("res://main.tscn")
