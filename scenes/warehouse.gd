extends Node2D

@onready var grid_container = $wares_UI/NinePatchRect/GridContainer
@onready var money_label = $wares_UI/MarginContainer/HBoxContainer/money_label
@onready var wares_slot = preload("res://inventory/wares_slot.tscn")

func _ready():
	update_wares()
	update_money()

func update_wares():
	for child in grid_container.get_children():
		child.queue_free()
	
	var wares = Global.get_wares()
	if wares:
		var stacked_items = {}
		
		for item in wares.items:
			if stacked_items.has(item.name):
				stacked_items[item.name].count += 1
			else:
				stacked_items[item.name] = {
					"item": item, 
					"count": 1
				}
		var sorted_item_names = stacked_items.keys()
		sorted_item_names.sort()
		
		for item_name in sorted_item_names:
			var item_data = stacked_items[item_name]
			var new_slot = wares_slot.instantiate()
			grid_container.add_child(new_slot)
		
		#for item_data in stacked_items.values():
			#var new_slot = wares_slot.instantiate()
			#grid_container.add_child(new_slot)
			
			if new_slot.has_method("set_item"):
				new_slot.set_item(item_data.item, item_data.count)


func update_money():
	money_label.text = str(Global.money)
