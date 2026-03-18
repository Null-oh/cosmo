extends Button

@onready var pause_menu = $"../../pause_container"

func _on_pressed():
	if pause_menu:
		if pause_menu.visible:
			pause_menu.visible = false
			Engine.time_scale = 1
		else:
			pause_menu.visible = true
			Engine.time_scale = -1
