extends CanvasLayer

@onready var fuel_bar = $fuel
@onready var pause_button = $VBoxContainer/pause
@onready var wares_button = $VBoxContainer/wares
@onready var map_button = $VBoxContainer/map
@onready var inv_button = $VBoxContainer/inventory

@onready var pause_menu = $pause_container
@onready var inv_ui = $inv_ui
@onready var mini_map = $mini_map

@export var inventory: Inv

func _ready():
	fuel_bar.min_value = 0
	fuel_bar.max_value = Global.max_fuel
	
	pause_button.pressed.connect(_on_pause_pressed)
	wares_button.pressed.connect(_on_wares_pressed)
	map_button.pressed.connect(_on_map_pressed)
	inv_button.pressed.connect(_on_inventory_pressed)

func _process(delta):
	update_time_scale()

func _physics_process(delta):
	fuel_bar.value = Global.current_fuel


func _on_pause_pressed():
	if pause_menu:
		pause_menu.visible = !pause_menu.visible
		update_time_scale()


func _on_wares_pressed():
	
	get_tree().change_scene_to_file("res://scenes/warehouse.tscn")
	
	#if inv_ui:
		#inv_ui.visible = !inv_ui.visible
		#update_time_scale()


func _on_map_pressed():
	if mini_map:
		mini_map.visible = !mini_map.visible
		update_time_scale()

func update_time_scale():
	var any_window_open = (
		(pause_menu and pause_menu.visible) or
		(inv_ui and inv_ui.visible) or
		(mini_map and mini_map.visible)
	)
	
	if any_window_open:
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1


func _on_inventory_pressed():
	if inv_ui:
		inv_ui.visible = !inv_ui.visible
		update_time_scale()
