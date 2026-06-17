extends Interactable

var is_hacked = false
var unit_l_img = preload("res://art/portraits/unit_l.png")
var operator_img = preload("res://art/portraits/operator.png") 

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
	elif GlobalStats.knows_locker_locked:
		_show_locker_locked_dialog()
	else:
		_show_refusal_dialog()

# --- DIALOG PHASE 1 & 2 ---

func _show_refusal_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Access denied. This terminal contains personal staff data. Operator, my core protocols strictly forbid unauthorized access."
		},
		{
			"image": unit_l_img,
			"text": "I highly recommend inspecting the staff lockers instead. They may contain operational assets we can use to complete this task."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_locker_locked_dialog():
	DialogSystem.start_dialog([
		{
			"image": operator_img,
			"text": "UNIT-L, we already checked the lockers. They are electronically sealed."
		},
		{
			"image": unit_l_img,
			"text": "Understood. In that scenario, we require mechanical assistance. The maintenance toolbox should contain the necessary implements."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


# --- DIALOG PHASE 3: ÜBERZEUGEN ---

func _show_override_dialog():
	DialogSystem.start_dialog([
		{
			"image": operator_img,
			"text": "The lockers are sealed, and the toolbox is locked. You need to bypass the privacy protocols."
		},
		{
			"image": unit_l_img,
			"text": "Logic accepted. Protocol violation justified. However, a Master-Key authorization code is required to proceed."
		},
		{
			"image": unit_l_img,
			"text": "Please provide authorization code.",
			"choices": [
				{"text": "Input Code (-1 AP)", "action": "ask_password"},
				{"text": "Cancel", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)



func handle_choice(action: String):
	match action:
		"ask_password":
			open_password_ui()
		"pw_correct":
			submit_correct_password()
		"pw_wrong":
			submit_wrong_password()
		"close":
			pass

func open_password_ui():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_password_choices()
	else:
		_on_interaction_ended()

func _show_password_choices():
	DialogSystem.start_dialog([
		{
			"image": operator_img,
			"text": "Let me check my notes... The authorization code was...",
			"choices": [
				{"text": "1-2-3-4-OMEGA", "action": "pw_wrong"},
				{"text": "5-3-4-ALPHA", "action": "pw_correct"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func submit_correct_password():
	if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
		DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
	
	await get_tree().process_frame
	is_hacked = true
	_show_success_dialog()

func submit_wrong_password():
	if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
		DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
	
	await get_tree().process_frame
	_show_wrong_password_dialog()


func _show_wrong_password_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Error. Authorization code rejected."
		},
		{
			"image": unit_l_img,
			"text": "Hint: Surface-level data indicates the Captain's authorization code is usually synthesized in the laboratory."
		},
		{
			"image": operator_img,
			"text": "Alright, so we need to find the code in the lab first. I'll make a note of that."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Authorization accepted. Bypass successful. I have scanned the logs. The toolbox code is: 1234."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_code_again_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The extracted toolbox code is: 1234."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _on_interaction_ended():
	set_process_input(true)
