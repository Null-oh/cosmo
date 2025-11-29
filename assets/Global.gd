extends Node

var money: int = 0

var max_fuel: float = 100.0
var current_fuel: float = 100.0

var speed: float = 200.0

var tick: float = 1.0

var ship_position: Vector2

var is_paused = false

var inventory: Inv
var wares: Wares
var upgrades_data: Dictionary

signal upgrades_applied

var to_drop_single = false

func _ready():
	if not inventory:
		inventory = Inv.new()
	if not wares:
		wares = Wares.new()
	
	init_upgrades()
	apply_all_upgrades()
	print("Global ready - upgrades applied")

func save_ship_state(position: Vector2):
	ship_position = position
	print("Position saved")

func get_ship_state():
	return {"position": ship_position}

func clear_ship_state():
	ship_position = Vector2.ZERO

func add_to_inventory(item: DropItem):
	if inventory and item:
		inventory.items.append(item)

func get_inventory(): 
	return inventory

func clear_inventory():
	if inventory:
		inventory.items.clear()

func add_to_wares(item: DropItem):
	if wares and item:
		wares.items.append(item)

func get_wares(): 
	return wares

func remove_from_wares(item_name: String, quantity: int):
	if not wares:
		return false
	
	var remaining_to_remove = quantity
	
	var i = 0
	while i < wares.items.size() and remaining_to_remove > 0:
		if wares.items[i].name == item_name:
			wares.items.remove_at(i)
			remaining_to_remove -= 1
		else:
			i += 1
	return remaining_to_remove == 0

func clear_wares():
	if wares:
		wares.items.clear()

func save_upgrade_level(upgrade_id: String, level: int):
	upgrades_data[upgrade_id] = level

func get_upgrade_level(upgrade_id: String, default_level: int = 0):
	return upgrades_data.get(upgrade_id, default_level)

func reset_upgrades():
	upgrades_data.clear()

func init_upgrades():
	var upgrades_db = preload("res://inventory/upgrades/AllUpgrades.tres")
	if upgrades_db:
		for upgrade in upgrades_db.upgrades:
			save_upgrade_level(upgrade.id, upgrade.initial_level)

func apply_all_upgrades():
	var upgrades_db = preload("res://inventory/upgrades/AllUpgrades.tres")
	if upgrades_db:
		for upgrade in upgrades_db.upgrades:
			var level = get_upgrade_level(upgrade.id)
			if level > 0:
				apply_upgrade(upgrade.feature, level)

func apply_upgrade(feature: String, level: int):
	match feature:
		"speed":
			speed = 200 + (level * 50)
			upgrades_applied.emit()
			print("Speed: ", speed)
			
		"fuel":
			max_fuel += (level * 50)
			upgrades_applied.emit()
			print("mfuel: ", max_fuel)
