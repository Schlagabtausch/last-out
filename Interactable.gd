extends Area2D
class_name Interactable

var player_in_range = false
@export var interact_text: String = "E - Interact"

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		if body.has_method("show_interaction_hint"):
			body.show_interaction_hint(interact_text)

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		if body.has_method("hide_interaction_hint"):
			body.hide_interaction_hint()
