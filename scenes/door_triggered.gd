extends Area2D

@export var retreat_direction: Vector2 = Vector2(0, 1)
@export var retreat_distance: float = 40.0

var unit_l_img = preload("res://art/portraits/unit_l.png")
var player_forced_to_retreat: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	var target_dog = get_tree().get_first_node_in_group("Enemy")
	
	if target_dog == null or target_dog.is_destroyed:
		return
		
	if body.is_in_group("Player"):
		if "is_frozen" in body:
			body.is_frozen = true
			
		if GlobalStats.has_weapon:
			_show_combat_dialog()
		else:
			player_forced_to_retreat = true 
			_show_retreat_dialog()


func _show_retreat_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "WARNING: Hostile robotic quadruped detected. Lethal threat level."
		},
		{
			"image": unit_l_img,
			"text": "We cannot pass. I highly advise retreating until we have acquired a suitable weapon."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_combat_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Hostile robotic quadruped blocking the path. With the gun equipped, I calculate a 98% chance of neutralizing it."
		},
		{
			"image": unit_l_img,
			"text": "Shall I engage?",
			"choices": [
				{"text": "Shoot (-1 AP)", "action": "shoot_dog"},
				{"text": "Retreat", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Threat neutralized. The quadruped is destroyed. The path ahead is clear."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func handle_choice(action: String):
	match action:
		"shoot_dog":
			player_forced_to_retreat = false
			shoot_dog()
		"close":
			player_forced_to_retreat = true
			_on_interaction_ended()

func shoot_dog():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		
		var target_dog = get_tree().get_first_node_in_group("Enemy")
		if target_dog:
			target_dog.destroy()
		
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_success_dialog()
	else:
		player_forced_to_retreat = true
		_on_interaction_ended()



func _on_interaction_ended():
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
		
	if player_forced_to_retreat:
		var tween = create_tween()
		var target_position = player.global_position + (retreat_direction.normalized() * retreat_distance)
		
		tween.tween_property(player, "global_position", target_position, 0.4)
		
		tween.tween_callback(func():
			if "is_frozen" in player:
				player.is_frozen = false
		)
	else:
		if "is_frozen" in player:
			player.is_frozen = false
