extends Button

func _ready():
	#pressed.connect(_on_pressed)
	pass

func _on_pressed():
	var ship = get_node("/root/space/ship")
	if ship:
		ship.go_to_base()
