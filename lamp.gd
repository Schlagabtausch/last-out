extends Node2D

@onready var light: PointLight2D = $PointLight2D

@export var base_energy: float = 0
@export var flicker_amount: float = 0.05
@export var flicker_speed: float = 8.0

var time := 0.0


func _process(delta: float) -> void:
	time += delta * flicker_speed
	var flicker := sin(time * 1.7) * flicker_amount + sin(time * 3.1) * flicker_amount * 0.5
	light.energy = base_energy + flicker
