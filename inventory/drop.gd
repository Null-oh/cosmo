extends Resource

class_name DropItem

@export var name: String = ""
@export var price: int = 0
@export var sprite: Texture2D

var drop_scene: PackedScene = preload("res://inventory/drop_scene.tscn")
