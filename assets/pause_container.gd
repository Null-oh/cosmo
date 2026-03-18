extends VBoxContainer

func _ready():
	self.visible = false

func _process(delta):
	if self.visible:
		Engine.time_scale = 0

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_continue_pressed():
	Engine.time_scale = 1
	self.visible = false
