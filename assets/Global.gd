extends Node

var money: int = 0
var fuel: float = 100.0
var max_fuel: float = 100.0
var current_fuel: float = 100.0
var tick: float = 1.0

var ship_position: Vector2

var is_paused = false

var inventory: Inv
var wares: Wares

var to_drop_single = false

func _ready():
	if not inventory:
		inventory = Inv.new()
	if not wares:
		wares = Wares.new()

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
		print("Added to inv: ", item.name)

func get_inventory(): return inventory

func clear_inventory():
	if inventory:
		inventory.items.clear()

func add_to_wares(item: DropItem):
	if wares and item:
		wares.items.append(item)
		print("Added to wares: ", item.name)

func get_wares(): return wares

func clear_wares():
	if wares:
		wares.items.clear()
