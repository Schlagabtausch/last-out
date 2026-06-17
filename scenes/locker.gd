extends Interactable

var is_open = false
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
	
	if is_open:
		_show_color_code_dialog()
		
	elif GlobalStats.has_crowbar:
		_show_crowbar_dialog()
		
	else:
		_show_locked_dialog()


func _show_locked_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The locker is sealed tight. My standard manipulators cannot open it normally. Should I try to force it?",
			"choices": [
				{"text": "Use brute force (-1 AP)", "action": "force_locker"},
				{"text": "Leave it", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_force_fail_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "WARNING: Actuator overload. The frame is reinforced steel. Brute force is completely ineffective here."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_crowbar_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The locker is locked. I could use the crowbar to pry it open.",
			"choices": [
				{"text": "Pry open (-1 AP)", "action": "open_locker"},
				{"text": "Leave it", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _show_color_code_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Inside the locker is a note. The color code is: RED - BLUE - GREEN - BLUE."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)



func handle_choice(action: String):
	match action:
		"force_locker":
			try_force_locker()
		"open_locker":
			pry_open_locker()
		"close":
			pass


func try_force_locker():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		
		GlobalStats.knows_locker_locked = true
		
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_force_fail_dialog()
	else:
		_on_interaction_ended()


func pry_open_locker():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		is_open = true
		
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_color_code_dialog()
	else:
		_on_interaction_ended()



func _on_interaction_ended():
	set_process_input(true)
