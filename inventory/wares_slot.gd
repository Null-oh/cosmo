extends Panel

var item: DropItem
var item_count: int = 1

@onready var texture_rect = $MarginContainer/VBoxContainer/TextureRect
@onready var price_label = $MarginContainer/VBoxContainer/HBoxContainer/price_label
@onready var quantity_label = $MarginContainer/VBoxContainer/HBoxContainer/quant_label

func set_item(new_item: DropItem, count: int = 1):
	item = new_item
	item_count = count
	
	if item:
		if texture_rect:
			texture_rect.texture = item.sprite
		if price_label:
			price_label.text = str(item.price)
		if quantity_label:
			quantity_label.text = str(count)


func _on_sell_button_pressed():
	if item:
		Global.money += item.price
	
		var wares = Global.wares
		
		if wares:
			var found_index = -1
			
			for i in range(wares.items.size()):
				if wares.items[i].name == item.name:
					found_index = i
					break
			if found_index != -1:
				wares.items.remove_at(found_index)
				print("Sold: ", item.name, " for ", item.price)

		
		item_count -= 1
		
		if item_count > 0:
			if quantity_label:
				quantity_label.text = str(item_count)

		else:
			self.queue_free()
		update_warehouse_ui()

func update_warehouse_ui():
	var warehouse = get_node_or_null("/root/warehouse")
	if warehouse and warehouse.has_method("update_wares"):
		warehouse.update_wares()
		warehouse.update_money()
