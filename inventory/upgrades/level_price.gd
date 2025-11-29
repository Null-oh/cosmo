extends Resource

class_name LevelPrice

@export var item1: PriceEntry
@export var item2: PriceEntry
@export var item3: PriceEntry

func get_prices() -> Array[PriceEntry]:
	var prices: Array[PriceEntry]
	if item1 and item1.quantity > 0:
		prices.append(item1)
	if item2 and item2.quantity > 0:
		prices.append(item2)
	if item3 and item3.quantity > 0:
		prices.append(item3)
	return prices
