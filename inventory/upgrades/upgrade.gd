extends Resource

class_name Upgrade

@export var id: String

@export var name: String

@export var feature: String

@export var texture: Texture2D
@export var initial_level: int = 1

@export var descriptions: Array[String]

@export var level_prices: Array[LevelPrice]

func get_level():
	var level = Global.get_upgrade_level(id, initial_level)
	return level

func set_level(value: int):
	Global.save_upgrade_level(id, value)

func get_prices_for_next_level():
	var current_level = get_level()
	if current_level < level_prices.size():
		return level_prices[current_level].get_prices()
	return []

func get_description():
	var current_level = get_level()
	if current_level < descriptions.size():
		return descriptions[current_level]
	elif descriptions.size() > 0:
		return descriptions[descriptions.size() - 1]
	else:
		return ""

func apply():
	var current_level = get_level()
	if current_level > 0 and Global.has_method(feature):
		Global.apply_upgrade(feature, current_level)
