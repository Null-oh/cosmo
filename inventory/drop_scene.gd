extends Area2D

@export var drop_item: DropItem

var lifetime: float
var life: float

enum drop_movement_type {fly, orbit}
var movement_type: drop_movement_type

@export var movement_speed: float = 0.0
@export var orbit_center: Vector2 = Vector2.ZERO
@export var orbit_radius: float = 0.0

var direction: Vector2 = Vector2.ZERO
var orbit_angle: float = 0.0
var orbit_time: float = 0.0

@onready var sprite_node = $Sprite2D

func _ready():
	life = 0.0
	if drop_item and sprite_node:
		sprite_node.texture = drop_item.sprite

func setup_drop_item(new_drop_item: DropItem):
	drop_item = new_drop_item
	if sprite_node:
		sprite_node.texture = drop_item.sprite

func setup_movement(type: drop_movement_type, speed: float, center: Vector2, radius: float = 0.0):
	movement_type = type
	movement_speed = speed
	orbit_center = center
	orbit_radius = radius
	
	if type == drop_movement_type.fly:
		direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	elif type == drop_movement_type.orbit:
		var offset = global_position - center
		orbit_angle = atan2(offset.y, offset.x)
	

func _physics_process(delta):
	match movement_type:
		drop_movement_type.fly:
			position += direction * movement_speed * delta
		drop_movement_type.orbit:
			orbit_time += delta
			var angular_speed = movement_speed / orbit_radius
			var angle = orbit_angle + orbit_time * angular_speed
			global_position = orbit_center + Vector2(cos(angle), sin(angle)) * orbit_radius
	if lifetime > 0.0:
		if life < lifetime:
			life += delta
		else:
			self.queue_free()
func pickup():
	if Global.current_fuel <= 0:
		return null
	if drop_item:
		queue_free()
		return drop_item
	return null
