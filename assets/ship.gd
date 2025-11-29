extends CharacterBody2D

var speed: float
@export var rotation_speed: float = 5.0
@export var tow_speed: float = 100.0

@export var tick: float = 1.0 #отладка

var target_position: Vector2
var is_moving: bool = false
var is_dragging: bool = false
var is_going_to_base: bool = false

var fuel_timer: float = 0.0
var was_towed: bool = false
var is_at_base: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var pickup_area = $pickup_area

@onready var inv_ui = get_node_or_null("/root/space/UI/inv_ui")

func _ready():
	if pickup_area:
		pickup_area.area_entered.connect(_on_pickup_area_entered)
	
	Global.upgrades_applied.connect(update_upgrades)
	load_ship_state()
	update_upgrades()
	

func update_upgrades():
	speed = Global.speed

func load_ship_state():
	var ship_state = Global.get_ship_state()
	if ship_state["position"] != Vector2.ZERO:
		global_position = ship_state["position"]

func _exit_tree():
	Global.save_ship_state(global_position)

func _input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		if _is_click_on_ui():
			return
		
		if is_going_to_base:
			is_going_to_base = false
			return
		
		if is_at_base:
			is_at_base = false
			was_towed = false
			Global.current_fuel = Global.max_fuel
			return
		
		if Global.current_fuel > 0 and not is_at_base:
			target_position = get_global_mouse_position()
			is_moving = true
			is_dragging = true
	
	if event is InputEventMouseMotion and is_dragging:
		if Global.current_fuel > 0 and not is_at_base:
			target_position = get_global_mouse_position()
			is_moving = true
	
	elif (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and not event.pressed):
		is_dragging = false 

func _is_click_on_ui():
	var mouse_pos = get_viewport().get_mouse_position()
	var ui_elements = get_tree().get_nodes_in_group("ui")
	for element in ui_elements:
		if element is Control and element.visible:
			var rect = Rect2(element.global_position, element.size)
			if rect.has_point(mouse_pos):
				return true
	return false

func _physics_process(delta):
	if is_at_base:
		target_position = Vector2.ZERO
		is_moving = false
		is_dragging = false
		is_going_to_base = false
		velocity = Vector2.ZERO
		return
	
	if Global.current_fuel > 0:
		if is_moving:
			var direction = global_position.direction_to(target_position)
			var distance = global_position.distance_to(target_position)
			
			if distance > 5.0:
				if sprite:
					var target_rotation = direction.angle() + PI/2
					sprite.rotation = lerp_angle(sprite.rotation, target_rotation, rotation_speed*delta)
					
				velocity = direction * speed
				move_and_slide()
				
				fuel_timer += delta
				if fuel_timer >= tick:
					Global.current_fuel -= 1
					fuel_timer = 0.0
				
			else:
				velocity = Vector2.ZERO
				is_moving = false
				#is_dragging = false
				is_going_to_base = false
				fuel_timer = 0.0
	else:
		var base_direction = global_position.direction_to(Vector2(0,0))
		velocity = base_direction * tow_speed
		move_and_slide()
		Global.clear_inventory()
		
		if inv_ui and inv_ui.has_method("update_inventory"):
			inv_ui.update_inventory()
		
		
		was_towed = true
		is_moving = false
		is_dragging = false
		is_going_to_base = false
	

func go_to_base(): 
	if not is_at_base and Global.current_fuel > 0:
		is_moving = true
		is_going_to_base = true
		target_position = Vector2(0,0)

func _on_pickup_area_entered(area):
	if area.has_method("pickup"):
		var drop_item = area.pickup()
		if drop_item:
			Global.add_to_inventory(drop_item)
			get_node("/root/space/UI/inv_ui").update_inventory()
