extends Path2D

@export var initial_health: int = -1
@onready var health: int
@export var is_breakable: bool = true

@onready var sprite = $Sprite2D
@export var texture: Sprite2D

@export var map_mark: Texture

#self movement
var initial_position: Vector2
@export var self_speed: float
@export var loop_path: bool
@export var auto_start: bool

@onready var path_follow = $PathFollow2D

var is_moving: bool

#drops
@export var drops: Array[DropEntry]
@export var drop_lifetime: float = 120

@export var timer: float = 0.0 #cd
@onready var timer_label = $timer_label
var time_passed: float = 0.0
var cd_flag: bool = false


#drill
var can_drill: bool = true #кд
@onready var drill_label = $drill_label
@onready var drill_button = $drill_button
@onready var no_drill = $no_drill

func _ready():
	
	health = initial_health
	drill_label.visible = false
	drill_label.text = "need drill"
	no_drill.visible = false
	drill_button.visible = false
	timer_label.visible = false
	
	if auto_start: 
		is_moving = true
	
	initial_position = self.position
	
	if path_follow:
		path_follow.rotates = true
	

func _process(delta):
	if is_moving and path_follow:
		path_follow.progress += delta * self_speed
		self.position = path_follow.position + initial_position
	
	if path_follow.progress_ratio >= 1.0 and not loop_path:
		is_moving = false
	
	
	
	
	if health == 0:
		match is_breakable:
			true:
				drop()
				self.queue_free()
			false:
				drill_button.visible = false
				can_drill = false
				cd_flag = true
				health = initial_health
				drop()

	
	if cd_flag:
		if !can_drill:
			time_passed += delta
			if time_passed <= timer:
				drill_button.visible = false
				timer_label.visible = true
				timer_label.text = str(int(timer - time_passed))
			else:
				timer_label.visible = false
				can_drill = true
				time_passed = 0.0




func drop():
	print(self.position)
	time_passed = 0
	for drop_entry in drops:
		if randf()* 100.0 <= drop_entry.probability:
			var amount = randi_range(drop_entry.min_amount, drop_entry.max_amount)
			for i in amount:
				if drop_entry.item.drop_scene:
					var item_instance = drop_entry.item.drop_scene.instantiate()
					
					item_instance.lifetime = self.drop_lifetime
					
					var spawn_position: Vector2
					var current_global_pos = path_follow.global_position #+ initial_position
					var angle = randf_range(0, TAU)
					var distance = randf_range(0, 50)
					#spawn_position = current_global_pos + Vector2(distance * cos(angle), distance * sin(angle))
					spawn_position = self.position + Vector2(distance * cos(angle), distance * sin(angle))
					print(spawn_position)
					get_tree().current_scene.add_child(item_instance)
					item_instance.global_position = spawn_position
					if item_instance.has_method("setup_drop_item"):
						item_instance.setup_drop_item(drop_entry.item)
				else: break

func _on_drill_button_pressed():
	if can_drill and health > 0:
		print("health ", self.health)
		match Global.boer:
			0: pass
			1: health -= 1
			2: health -= 2
			3: health -= 5
	else: pass

func _on_area_2d_body_entered(body):
	if body.name == "ship":
		if Global.boer == 0:
			no_drill.visible = true
		else:
			drill_button.visible = true


func _on_area_2d_body_exited(body):
	if body.name == "ship":
		if Global.boer == 0:
			no_drill.visible = false
		else:
			drill_button.visible = false
