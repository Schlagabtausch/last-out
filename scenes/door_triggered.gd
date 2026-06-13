extends Area2D

@export var retreat_direction: Vector2 = Vector2(0, 1) # Standard: Nach unten (0, 1)
@export var retreat_distance: float = 40.0 # Wie viele Pixel soll er zurückgehen?

var unit_l_img = preload("res://art/portraits/unit_l.png")
var player_forced_to_retreat: bool = false # Merkt sich, ob wir fliehen

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
			# Keine Waffe = Wir MÜSSEN fliehen
			player_forced_to_retreat = true 
			_show_retreat_dialog()

# --- DIALOGE ---

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
			"text": "Hostile robotic quadruped blocking the path. With the heavy sidearm equipped, I calculate a 98% chance of neutralizing it."
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

# --- AKTIONEN ---

func handle_choice(action: String):
	match action:
		"shoot_dog":
			player_forced_to_retreat = false # Wir kämpfen, also nicht fliehen!
			shoot_dog()
		"close":
			player_forced_to_retreat = true # Wir haben "Retreat" gewählt
			# Da wir hier keinen neuen Dialog starten, beenden wir es manuell:
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
		print("Nicht genug AP zum Schießen!")
		player_forced_to_retreat = true # Ohne AP müssen wir doch fliehen
		_on_interaction_ended()


# --- HILFSFUNKTION (MIT TWEEN) ---

func _on_interaction_ended():
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return
		
	if player_forced_to_retreat:
		# Wenn der Spieler fliehen muss, schieben wir ihn sanft zurück
		var tween = create_tween()
		var target_position = player.global_position + (retreat_direction.normalized() * retreat_distance)
		
		# Bewegt den Spieler in 0.4 Sekunden auf die neue Position
		tween.tween_property(player, "global_position", target_position, 0.4)
		
		# Erst NACHDEM die Bewegung fertig ist, darf der Spieler sich wieder bewegen
		tween.tween_callback(func():
			if "is_frozen" in player:
				player.is_frozen = false
		)
	else:
		# Wenn er gekämpft hat, einfach sofort entfrieren
		if "is_frozen" in player:
			player.is_frozen = false
