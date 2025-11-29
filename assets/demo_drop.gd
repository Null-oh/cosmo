extends Node2D

@onready var sprite = $AnimatedSprite2D
@export var value : int

func _ready():
	match value:
		1: sprite.play("one")
		2: sprite.play("two")
		3: sprite.play("three")
		4: sprite.play("four")
		5: sprite.play("five")
		6: sprite.play("six")


#func _on_area_2d_body_entered(body):
	#if body.name == "ship":
		#print("drop")
