extends Button

func _ready():
	pass

func _on_pressed():
	var inv_ui = get_node("/root/space/UI/inv_ui")
	if inv_ui:
		inv_ui.switch()
