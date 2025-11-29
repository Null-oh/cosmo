extends Path2D

#drops
@export_category("Item Drops")
@export var drops: Array[DropEntry]

#self coords
var center: Vector2

#timed drops
@export var timer: int
var _timer: float
var time_passed: float = 0.0
@export var lifetime: float = 0.0

#drop movement
@export var drop_speed: float
enum drop_movement_type {fly, orbit}
@export var drop_movement: drop_movement_type
@export_range(0, 100, 1, "suffix: px") var orbit: int

#self movement
@export var self_speed: float
@export var loop_path: bool
@export var auto_start: bool

@onready var path_follow = $PathFollow2D

var is_moving: bool

func _ready():
	center = position
	_timer = float(timer)
	
	if auto_start: 
		is_moving = true

func _process(delta):
	if is_moving and path_follow:
		path_follow.progress += delta * self_speed
	
	if path_follow.progress_ratio >= 1.0 and not loop_path:
		is_moving = false

func _physics_process(delta):
	if timer == 0 and Global.to_drop_single:
		drop_single()
	elif timer > 0:
		time_passed += delta
		if time_passed >= _timer:
			spawn()
			time_passed = 0.0

func set_progress_ratio(ratio: float):
	if path_follow:
		path_follow.progress_ratio = ratio

func get_progress_ratio():
	if path_follow:
		return path_follow.progress_ratio
	else:
		return 0.0

func spawn():
	for drop_entry in drops:
		if randf()* 100.0 <= drop_entry.probability:
			var amount = randi_range(drop_entry.min_amount, drop_entry.max_amount)
			for i in amount:
				var item_instance = drop_entry.item.drop_scene.instantiate()
				
				item_instance.lifetime = self.lifetime
				
				var spawn_position: Vector2
				
				var current_global_pos = path_follow.global_position
				
				match drop_movement:
					drop_movement_type.fly:
						spawn_position = current_global_pos
					drop_movement_type.orbit:
						var random_angle = randf_range(0, TAU)
						spawn_position = current_global_pos + Vector2(cos(random_angle), sin(random_angle)) * orbit
				
				instantiate_item(item_instance, spawn_position, drop_entry.item)
				

func instantiate_item(item_instance, spawn_position: Vector2, drop_item_resource: DropItem):
	get_tree().current_scene.add_child(item_instance)
	item_instance.global_position = spawn_position
	
	if item_instance.has_method("setup_drop_item"):
		item_instance.setup_drop_item(drop_item_resource)
	
	match drop_movement:
		drop_movement_type.fly:
			item_instance.setup_movement(drop_movement_type.fly, drop_speed, center, 0.0)
		drop_movement_type.orbit:
			item_instance.setup_movement(drop_movement_type.orbit, drop_speed, center, orbit)

func drop_single():
	Global.to_drop_single = false
