extends CanvasLayer

@onready var fuel_bar = $fuel
@onready var pause_button = $VBoxContainer/pause
@onready var wares_button = $VBoxContainer/wares

@export var inventory: Inv

func _ready():
	fuel_bar.min_value = 0
	fuel_bar.max_value = Global.max_fuel

func _physics_process(delta):
	fuel_bar.value = Global.current_fuel
