extends Control

@onready var grid_container = $NinePatchRect/GridContainer
@onready var slot_scene = preload("res://inventory/ui_slot.tscn")

func _ready():
	self.visible = false
	mouse_filter = MOUSE_FILTER_STOP
	update_inventory()

func update_inventory():
	for child in grid_container.get_children():
		child.queue_free()
	
	var inventory = Global.get_inventory()
	if inventory:
		var stacked_items = {}
		
		for item in inventory.items:
			if stacked_items.has(item.name):
				stacked_items[item.name].count += 1
			else:
				stacked_items[item.name] = {
					"item": item, 
					"count": 1
				}
		for item_data in stacked_items.values():
			var new_slot = slot_scene.instantiate()
			grid_container.add_child(new_slot)
			
			if new_slot.has_method("set_item"):
				new_slot.set_item(item_data.item, item_data.count)
	

