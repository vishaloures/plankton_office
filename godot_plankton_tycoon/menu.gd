extends Control

@onready var form_option = $VBoxContainer/FormBox/FormOption
@onready var basic_option = $VBoxContainer/BasicBox/BasicOption
@onready var super_option = $VBoxContainer/SuperBox/SuperOption
@onready var name_input = $VBoxContainer/NameBox/NameInput

func _ready():
	form_option.add_item("Краб (Клешни стучат быстрее)")
	form_option.add_item("Планктон (Один глаз, но большой)")
	
	basic_option.add_item("Программист (Быстрый код, быстрое выгорание)")
	basic_option.add_item("Менеджер (Медленно работает, мало ест)")
	basic_option.add_item("Дизайнер (Средне работает, постоянно душно)")
	
	super_option.add_item("Пукун (Регулярные газовые атаки)")
	super_option.add_item("Сонный алкоголик (Внезапные приступы усталости)")
	super_option.add_item("Токсичный сарказм (Быстро выгорает сам и бесит всех)")
	
	name_input.text = "Геннадий"

func _on_start_pressed():
	Global.character_form = "Crab" if form_option.selected == 0 else "Plankton"
	
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
