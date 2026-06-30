extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Area2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var door_open_sound: AudioStreamPlayer2D = $DoorOpenSound
@onready var light_occluder: LightOccluder2D = $LightOccluder2D

const ANIMATION_NAME: StringName = &"open_close"

enum DoorState {
	CLOSED,
	OPENING,
	OPEN,
	CLOSING
}

var state: DoorState = DoorState.CLOSED
var player_inside: bool = false


func _ready() -> void:
	animated_sprite.animation = ANIMATION_NAME
	animated_sprite.frame = 0
	animated_sprite.stop()
	animated_sprite.speed_scale = 1.0

	door_collision.set_deferred("disabled", false)

	# Tür startet geschlossen, also blockiert sie Licht.
	light_occluder.visible = true

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = true
	call_deferred("_request_open")


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = false
	call_deferred("_request_close")


func _request_open() -> void:
	if state == DoorState.OPEN or state == DoorState.OPENING:
		return

	_open_door()


func _request_close() -> void:
	if player_inside:
		return

	if state == DoorState.CLOSED or state == DoorState.CLOSING:
		return

	_close_door()


func _open_door() -> void:
	state = DoorState.OPENING

	# Beim Öffnen blockiert die Tür nicht mehr.
	door_collision.set_deferred("disabled", true)
	light_occluder.visible = false

	_play_door_sound()

	animated_sprite.speed_scale = 1.0
	animated_sprite.play(ANIMATION_NAME)


func _close_door() -> void:
	state = DoorState.CLOSING

	# Beim Schließen soll die Tür wieder blockieren.
	door_collision.set_deferred("disabled", false)
	light_occluder.visible = true

	var last_frame := animated_sprite.sprite_frames.get_frame_count(ANIMATION_NAME) - 1

	if animated_sprite.frame < last_frame:
		animated_sprite.frame = last_frame

	_play_door_sound()

	animated_sprite.speed_scale = -1.0
	animated_sprite.play(ANIMATION_NAME)


func _play_door_sound() -> void:
	if door_open_sound == null:
		return

	door_open_sound.stop()
	door_open_sound.play()


func _on_animation_finished() -> void:
	if animated_sprite.speed_scale > 0.0:
		state = DoorState.OPEN

		var last_frame := animated_sprite.sprite_frames.get_frame_count(ANIMATION_NAME) - 1
		animated_sprite.frame = last_frame
		animated_sprite.stop()

		door_collision.set_deferred("disabled", true)
		light_occluder.visible = false

		if not player_inside:
			call_deferred("_request_close")

	else:
		state = DoorState.CLOSED

		animated_sprite.frame = 0
		animated_sprite.stop()
		animated_sprite.speed_scale = 1.0

		door_collision.set_deferred("disabled", false)
		light_occluder.visible = true

		if player_inside:
			call_deferred("_request_open")
