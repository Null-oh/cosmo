extends Node2D

@onready var inv_ui = get_tree().get_first_node_in_group("inventory_ui")

@onready var map_mark = preload("res://img/demo_drop/sprite_5.png")

func _on_area_2d_body_entered(body):
	if body.name == "ship":
		body.is_at_base = true
		Global.current_fuel = Global.max_fuel
		_transfer_inventory()

func _transfer_inventory():
	var inventory = Global.get_inventory()
	var wares = Global.get_wares()
	
	if inventory and wares:
		for item in inventory.items:
			wares.items.append(item)
	
	Global.clear_inventory()
	
	inv_ui.update_inventory()
