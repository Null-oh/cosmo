extends Button

@onready var inventory = get_node("/root/space/UI/inv_ui")
@onready var mini_map = get_node("/root/space/UI/mini_map")

func _on_pressed():
	if mini_map:
		mini_map.visible = !mini_map.visible
		if !inventory.visible:
			Engine.time_scale = Engine.time_scale + (-1)**(Engine.time_scale)
