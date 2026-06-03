extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var patrol_distance: float = 128.0
@export var move_speed: float = 45.0
@export var wait_time: float = 0.4

@export_enum("right", "left", "up", "down") var patrol_direction: String = "right"

var patrol_timer: Timer

var start_position: Vector2
var target_position: Vector2
var moving_to_target: bool = true
var waiting: bool = false
var last_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	start_position = global_position
	target_position = start_position + _direction_to_vector(patrol_direction) * patrol_distance

	patrol_timer = Timer.new()
	patrol_timer.name = "PatrolTimer"
	patrol_timer.one_shot = true
	patrol_timer.wait_time = wait_time
	add_child(patrol_timer)
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)

	last_direction = _direction_to_vector(patrol_direction)
	_play_idle_animation(last_direction)


func _physics_process(_delta: float) -> void:
	if waiting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var destination := target_position if moving_to_target else start_position
	var to_destination := destination - global_position

	if to_destination.length() <= 2.0:
		_arrive_at_patrol_point()
		return

	var direction := to_destination.normalized()
	last_direction = direction

	velocity = direction * move_speed
	move_and_slide()

	_play_walk_animation(direction)


func _arrive_at_patrol_point() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

	waiting = true
	moving_to_target = not moving_to_target

	_play_idle_animation(last_direction)
	patrol_timer.start()


func _on_patrol_timer_timeout() -> void:
	waiting = false


func _direction_to_vector(direction_name: String) -> Vector2:
	match direction_name:
		"right":
			return Vector2.RIGHT
		"left":
			return Vector2.LEFT
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		_:
			return Vector2.RIGHT


func _play_walk_animation(direction: Vector2) -> void:
	var animation_name := _direction_to_animation_name(direction, "walk")

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)


func _play_idle_animation(direction: Vector2) -> void:
	var animation_name := _direction_to_animation_name(direction, "idle")

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)


func _direction_to_animation_name(direction: Vector2, prefix: String) -> String:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0.0:
			return prefix + "_right"
		else:
			return prefix + "_left"
	else:
		if direction.y > 0.0:
			return prefix + "_down"
		else:
			return prefix + "_up"
