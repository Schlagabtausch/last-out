extends Camera2D

@export var target_zoom: Vector2 = Vector2(2.0, 2.0)
@export var vertical_offset: float = -30.0
@export var smoothing_speed_value: float = 6.0

func _ready() -> void:
	enabled = true
	zoom = target_zoom
	position = Vector2(0.0, vertical_offset)
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed_value
