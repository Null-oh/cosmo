extends Button

func _on_pressed():
	var ship = get_node("/root/space/ship")
	if ship:
		ship.go_to_base()
