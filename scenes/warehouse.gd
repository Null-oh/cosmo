extends Node2D

@onready var wares_container = $wares_UI/Control/VBoxContainer/TabContainer/wares_tab/NinePatchRect/MarginContainer/wares_grid_container
@onready var upgrades_container = $wares_UI/Control/VBoxContainer/TabContainer/upgrades_tab/NinePatchRect2/MarginContainer/upgrades_grid_container

@export var upgrades_database: UpgradesDatabase

@onready var money_label = $wares_UI/Control/VBoxContainer/MarginContainer/HBoxContainer/money_label

@onready var wares_slot = preload("res://inventory/wares_slot.tscn")
@onready var upgrade_slot = preload("res://inventory/upgrades/upgrade_slot.tscn")

@onready var tab_container = $wares_UI/Control/VBoxContainer/TabContainer

func _ready():
	update_labels()
	update_wares()
	update_money()
	
	update_upgrades()

func update_wares():
	for child in wares_container.get_children():
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
			wares_container.add_child(new_slot)
			
			if new_slot.has_method("set_item"):
				new_slot.set_item(item_data.item, item_data.count)

func update_upgrades():
	if not upgrades_database or not upgrade_slot or not upgrades_container:
		return
	
	for child in upgrades_container.get_children():
		child.queue_free()
	
	for upgrade in upgrades_database.upgrades:
		var slot_instance = upgrade_slot.instantiate()
		upgrades_container.add_child(slot_instance)
		
		set_upgrade_slot(slot_instance, upgrade)

func set_upgrade_slot(slot, upgrade):
	var title_label = slot.find_child("title")
	var description_label = slot.find_child("description")
	var upgrade_texture = slot.find_child("upgrade_texture")
	var buy_button = slot.find_child("buy_button")
	
	if title_label:
		title_label.text = upgrade.name
	if description_label:
		description_label.text = upgrade.get_description()
	if upgrade_texture and upgrade.texture:
		upgrade_texture.texture = upgrade.texture
	
	setup_prices(slot, upgrade)
	
	if buy_button:
		var current_level = upgrade.get_level()
		
		if current_level >= 3:
			buy_button.disabled = true
			buy_button.text = "Максимум"
		else:
			if can_afford_upgrade(upgrade):
				buy_button.disabled = false
				buy_button.text = "Купить"
			else:
				buy_button.disabled = true
				buy_button.text = "Недостаточно"
		
		if buy_button.is_connected("pressed", _on_buy_button_pressed):
			buy_button.pressed.disconnect(_on_buy_button_pressed)
		buy_button.pressed.connect(_on_buy_button_pressed.bind(upgrade))

func setup_prices(slot, upgrade):
	
	var current_level = upgrade.get_level()
	
	if current_level >= 3:
		for i in range (1, 4):
			var price_slot = slot.find_child("price" + str(i))
			if price_slot:
				price_slot.visible = false
	
	var price_slots = [
		slot.find_child("price1"),
		slot.find_child("price2"),
		slot.find_child("price3")
	]
	
	var next_prices = upgrade.get_prices_for_next_level()
	
	for price_slot in price_slots:
		if price_slot:
			price_slot.visible = false
	
	for i in range(next_prices.size()):
		if i >= price_slots.size():
			break
		
		var price_slot = price_slots[i]
		var price_entry = next_prices[i]
		
		if price_slot and price_entry and price_entry.quantity > 0:
			price_slot.visible = true
			
			var item_texture = price_slot.find_child("item_texture")
			var name_label = price_slot.find_child("item_name")
			var quantity_label = price_slot.find_child("item_quantity")
			
			var drop_item: DropItem = price_entry.item
			
			if item_texture and drop_item:
				item_texture.texture = drop_item.sprite
			if name_label and drop_item:
				name_label.text = drop_item.name
			if quantity_label:
				quantity_label.text = "x" + str(price_entry.quantity)

func _on_buy_button_pressed(upgrade: Upgrade):
	var current_level = upgrade.get_level()
	if current_level < 3 and can_afford_upgrade(upgrade):
		spend_upgrade_resources(upgrade)
		upgrade.set_level(current_level + 1)
		Global.apply_upgrade(upgrade.feature, current_level + 1)
	update_upgrades()
	update_wares()
	update_money()

func can_afford_upgrade(upgrade: Upgrade):
	var current_level = upgrade.get_level()
	if current_level >= 3:
		return false
	
	var next_prices = upgrade.get_prices_for_next_level()
	var wares = Global.get_wares()
	
	if not wares:
		return false
	
	var available_resources = {}
	for item in wares.items:
		if available_resources.has(item.name):
			available_resources[item.name] += 1
		else:
			available_resources[item.name] = 1
	
	for price_entry in next_prices:
		var required_item_name = price_entry.item.name
		var required_quantity = price_entry.quantity
		
		if not available_resources.has(required_item_name) or available_resources[required_item_name] < required_quantity:
			return false
	
	return true

func spend_upgrade_resources(upgrade: Upgrade):
	var next_prices = upgrade.get_prices_for_next_level()
	
	for price_entry in next_prices:
		var required_item_name = price_entry.item.name
		var required_quantity = price_entry.quantity
		
		Global.remove_from_wares(required_item_name, required_quantity)

func update_money():
	money_label.text = str("Деньги: ", Global.money)

func update_labels():
	tab_container.set_tab_title(0, "")
	tab_container.set_tab_title(1, "")
