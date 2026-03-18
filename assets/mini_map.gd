extends Control

@onready var map_texture = $TextureRect

var map_center

@onready var ship = get_tree().get_first_node_in_group("ship")
var ship_mark

#@onready var to_mark: Array[Node]

@onready var marks_container = $TextureRect/MarksContainer
var object_marks = {}

@export var map_scale: float = 0.05

@export var min_scale: float = 0.01
@export var max_scale: float = 0.2

@export var zoom_step: float = 0.05
var previous_ship_position: Vector2

#var drag_offset = Vector2.ZERO
#var is_dragging = false
#var drag_start_mouse_pos = Vector2.ZERO
#var drag_start_offset = Vector2.ZERO

@onready var grid_container = $TextureRect/GridContainer
@export var grid_step: float = 1000.0
@export var grid_color: Color = Color.WHITE
@export var grid_width: float = 1.0
var grid_lines = []

func _ready():
	self.visible = false
	
	await get_tree().process_frame
	
	map_center = map_texture.size / 2
	
	if not marks_container:
		marks_container = Node2D.new()
		marks_container.name = "MarksContainer"
		map_texture.add_child(marks_container)
	
	if not grid_container:
		grid_container = Node2D.new()
		grid_container.name = "GridContainer"
		map_texture.add_child(grid_container)
	create_grid()
	
	#map_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if ship:
		previous_ship_position = ship.position

func _process(delta):
	map_center = map_texture.size / 2
	mark_all()

func switch():
	self.visible = !self.visible
	Engine.time_scale = Engine.time_scale + (-1)**(Engine.time_scale)

func _input(event):
	if not self.visible:
		return
	
	if event is InputEventMouseButton and self.visible:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	
	#if event is InputEventMouseButton and self.visible:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom_in(event.position)
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom_out(event.position)


func zoom_in():
	if map_scale < max_scale:
		var old_scale = map_scale
		map_scale = min(map_scale + zoom_step, max_scale)
		adjust_positions_after_zoom(old_scale)
		update_grid()

func zoom_out():
	if map_scale > min_scale:
		var old_scale = map_scale
		map_scale = max(map_scale - zoom_step, min_scale)
		adjust_positions_after_zoom(old_scale)
		update_grid()



func adjust_positions_after_zoom(old_scale):
	if old_scale == 0:
		return
	map_center = map_texture.size / 2
	mark_all()

func mark_all():
	if not ship or not is_instance_valid(ship):
		return
	
	map_center = map_texture.size / 2
	var ship_pos = ship.position
	
	var objects = get_tree().get_nodes_in_group("to_map")
	
	var map_rect = Rect2(Vector2.ZERO, map_texture.size)
	
	var objects_to_remove = []
	for object in object_marks:
		if not is_instance_valid(object) or not object in objects:
			objects_to_remove.append(object)
	
	for object in objects_to_remove:
		var mark = object_marks[object]
		if is_instance_valid(mark):
			mark.queue_free()
		object_marks.erase(object)
	
	for object in objects:
		if is_instance_valid(object):
			
			var relative_pos = object.position - ship_pos
			
			#var position_on_map = Vector2(
				#floor(map_scale * object.position.x) + map_center.x,
				#floor(map_scale * object.position.y) + map_center.y
			#)
			
			var position_on_map = Vector2(
				floor(map_scale * relative_pos.x) + map_center.x,
				floor(map_scale * relative_pos.y) + map_center.y
			)
			
			#position_on_map.x = clamp(position_on_map.x, 0, map_texture.size.x)
			#position_on_map.y = clamp(position_on_map.y, 0, map_texture.size.y)
			
			var is_inside = map_rect.has_point(position_on_map)
			
			if not object_marks.has(object):
				if is_inside:
					create_mark_for_object(object, position_on_map)
			else:
				var mark = object_marks[object]
				if is_instance_valid(mark):
					if is_inside:
						mark.position = position_on_map
						mark.visible = true
					else:
						mark.visible = false
				else:
					object_marks.erase(object)
					if is_inside:
						create_mark_for_object(object, position_on_map)

func create_mark_for_object(object, position):
		var mark = Sprite2D.new()

		if object.map_mark:
			mark.texture = object.map_mark
		
		mark.position = position
		marks_container.add_child(mark)
		object_marks[object] = mark

func create_grid():
	clear_grid()
	
	if not ship or not is_instance_valid(ship):
		return
	
	var map_size = map_texture.size
	var ship_pos = ship.position
	
	var step_in_pixels = grid_step * map_scale
	
	if step_in_pixels < 10.0:
		step_in_pixels = 10.0
	elif step_in_pixels > map_size.x / 2:
		step_in_pixels = map_size.x / 4
	
	var zero_x = map_center.x
	var zero_y = map_center.y
	
	var x = zero_x
	while x < map_size.x:
		create_grid_line(Vector2(x, 0), Vector2(x, map_size.y))
		x += step_in_pixels
	
	x = zero_x - step_in_pixels
	while x >= 0:
		create_grid_line(Vector2(x, 0), Vector2(x, map_size.y))
		x -= step_in_pixels
	
	var y = zero_y
	while y < map_size.y:
		create_grid_line(Vector2(0, y), Vector2(map_size.x, y))
		y += step_in_pixels
	
	y = zero_y - step_in_pixels
	while y >= 0:
		create_grid_line(Vector2(0, y), Vector2(map_size.x, y))
		y -= step_in_pixels
	
	var center_line = Line2D.new()
	center_line.add_point(Vector2(zero_x, 0))
	center_line.add_point(Vector2(zero_x, map_size.y))
	center_line.width = grid_width * 2
	center_line.default_color = grid_color.lightened(0.3)
	grid_container.add_child(center_line)
	grid_lines.append(center_line)
	
	center_line = Line2D.new()
	center_line.add_point(Vector2(0, zero_y))
	center_line.add_point(Vector2(map_size.x, zero_y))
	center_line.width = grid_width * 2
	center_line.default_color = grid_color.lightened(0.3)
	grid_container.add_child(center_line)
	grid_lines.append(center_line)

func create_grid_line(from: Vector2, to: Vector2):
	var line = Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.width = grid_width
	line.default_color = grid_color
	line.antialiased = true
	
	grid_container.add_child(line)
	grid_lines.append(line)

func update_grid():
	for line in grid_lines:
		if is_instance_valid(line):
			line.queue_free()
	grid_lines.clear()
	create_grid()

func clear_grid():
	for line in grid_lines:
		if is_instance_valid(line):
			line.queue_free()
	grid_lines.clear()
