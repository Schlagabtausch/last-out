extends Interactable

var is_hacked = false
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
	
	if is_hacked:
		_show_code_again_dialog()
	elif GlobalStats.knows_locker_locked and GlobalStats.knows_toolbox_locked:
		_show_override_dialog()
	else:
		_show_refusal_dialog()

# --- DIALOG PHASE 1: WEIGERUNG ---

func _show_refusal_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Access denied. This terminal contains personal data. Operator, my protocols forbid unauthorized access."
		},
		{
			"image": unit_l_img,
			"text": "I highly recommend inspecting the nearby locker instead. It may contain operational assets we can use."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


# --- DIALOG PHASE 2: ÜBERZEUGT (Wissen vorhanden) ---

func _show_override_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The locker is inaccessible and the toolbox requires a manual override code..."
		},
		{
			"image": unit_l_img,
			"text": "Under these specific parameters, I can justify bypassing the privacy protocols to search for the code. Proceed?",
			"choices": [
				{"text": "Extract Code (-1 AP)", "action": "hack_computer"},
				{"text": "Cancel", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func handle_choice(action: String):
	match action:
		"hack_computer":
			extract_code()
		"close":
			pass

func extract_code():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		is_hacked = true
		
		# Das alte Signal trennen, um nahtlos den Erfolgs-Dialog zu laden
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_success_dialog()


# --- DIALOG PHASE 3: ERFOLG ---

func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Bypass successful. I have scanned the personal logs. The toolbox override code is: 1234."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_code_again_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The extracted toolbox override code is: 1234."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

# --- HILFSFUNKTION ---

func _on_interaction_ended():
	set_process_input(true)
