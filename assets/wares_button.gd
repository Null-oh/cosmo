extends Button

@onready var ship = get_node("/root/space/ship")

func _process(delta):
	if ship:
		if ship.is_at_base:
			self.visible = true
		else:
			self.visible = false

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/warehouse.tscn")
