extends Interactable

var cell_taken = false
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
	
	if cell_taken:
		_show_empty_dialog()
	else:
		_show_extract_dialog()


func _show_extract_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "I've located a functional energy cell inside this compartment. Should I extract it?",
			"choices": [
				{"text": "Extract Cell (-1 AP)", "action": "extract_cell"},
				{"text": "Leave it", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_empty_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The compartment is empty. The energy cell has already been removed."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Energy cell successfully extracted and added to inventory."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func handle_choice(action: String):
	match action:
		"extract_cell":
			extract_cell()
		"close":
			pass

func extract_cell():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		cell_taken = true
		GlobalStats.has_cell = true
		
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_success_dialog()
		
	else:
		_on_interaction_ended()

func _on_interaction_ended():
	set_process_input(true)
