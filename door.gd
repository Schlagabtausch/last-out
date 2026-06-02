extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Area2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

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

	# Während die Tür öffnet, soll sie nicht mehr blockieren.
	door_collision.set_deferred("disabled", true)

	animated_sprite.speed_scale = 1.0
	animated_sprite.play(ANIMATION_NAME)


func _close_door() -> void:
	state = DoorState.CLOSING

	# Wichtig: deferred, sonst kommt dein Fehler.
	door_collision.set_deferred("disabled", false)

	var last_frame := animated_sprite.sprite_frames.get_frame_count(ANIMATION_NAME) - 1

	# Falls die Tür gerade offen steht, sicherstellen, dass sie am letzten Frame startet.
	if animated_sprite.frame < last_frame:
		animated_sprite.frame = last_frame

	animated_sprite.speed_scale = -1.0
	animated_sprite.play(ANIMATION_NAME)


func _on_animation_finished() -> void:
	if animated_sprite.speed_scale > 0.0:
		# Öffnungsanimation fertig.
		state = DoorState.OPEN

		var last_frame := animated_sprite.sprite_frames.get_frame_count(ANIMATION_NAME) - 1
		animated_sprite.frame = last_frame
		animated_sprite.stop()

		door_collision.set_deferred("disabled", true)

		# Falls der Player während des Öffnens schon wieder raus ist:
		if not player_inside:
			call_deferred("_request_close")

	else:
		# Schließanimation fertig.
		state = DoorState.CLOSED

		animated_sprite.frame = 0
		animated_sprite.stop()
		animated_sprite.speed_scale = 1.0

		door_collision.set_deferred("disabled", false)

		# Falls der Player während des Schließens wieder reinläuft:
		if player_inside:
			call_deferred("_request_open")
