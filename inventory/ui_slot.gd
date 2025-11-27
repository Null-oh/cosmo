extends Panel

@onready var texture_rect = $TextureRect
@onready var count_label = $Label

func set_item(item: DropItem, count: int = 1):
	if texture_rect and item:
		texture_rect.texture = item.sprite
		texture_rect.visible = true
		
		if count > 1:
			count_label.text = str(count)
			count_label.visible = true
		else:
			count_label.visible = false
	else:
		texture_rect.visible = false
		count_label.visible = false
