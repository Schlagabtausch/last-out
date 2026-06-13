extends Interactable

var is_activated = false
var unit_l_img = preload("res://art/portraits/unit_l.png")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event):
	if get_viewport().gui_get_focus_owner() != null:
		return 

	if player_in_range and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		use_object()

func use_object():
	set_process_input(false)
	
	if is_activated:
		_on_interaction_ended()
		return # Verhindert, dass man mehrmals sendet
		
	# Kein Inventar-Check mehr, direkt zum Sende-Dialog!
	_show_core_dialog()

# --- DIALOGE ---

func _show_core_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Quantum Core terminal accessed. The main transmitter is online and locked onto command's frequency."
		},
		{
			"image": unit_l_img,
			"text": "Ready to transmit the research data.",
			"choices": [
				{"text": "Transmit Data (-1 AP)", "action": "transmit"},
				{"text": "Cancel", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_victory_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Transmission complete. Data successfully received by command."
		},
		{
			"image": unit_l_img,
			"text": "Mission Accomplished. My primary directive is fulfilled. Initiating sleep mode..."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_victory_ended, CONNECT_ONE_SHOT)

# --- AKTIONEN ---

func handle_choice(action: String):
	match action:
		"transmit":
			transmit_data()
		"close":
			pass

func transmit_data():
	if GlobalStats.current_ap >= 1:
		#GlobalStats.current_ap -= 1
		is_activated = true
		
		# Das Standard-Ende-Signal trennen, damit der Input nicht zu früh freigegeben wird
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_victory_dialog()
	else:
		print("Nicht genug AP zum Senden!")
		_on_interaction_ended()

# --- HILFSFUNKTIONEN ---

func _on_interaction_ended():
	set_process_input(true)

func _on_victory_ended():
	# HIER PASSIERT DER GEWINN!
	print("MISSION ERFOLGREICH! SPIEL BEENDET!")
	
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
