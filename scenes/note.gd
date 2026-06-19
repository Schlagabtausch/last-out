extends Interactable

var unit_l_img = preload("res://art/portraits/unit_l.png")
var operator_img = preload("res://art/portraits/operator.png") 

var has_been_read = false

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
	
	if has_been_read:
		_show_read_again_dialog()
	else:
		_show_discovery_dialog()

func _show_discovery_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Scanning physical document... The text contains a a series of numbers: '734'."
		},
		{
			"image": unit_l_img,
			"text": "High probability: This is the password for the primary Analysis Terminal."
		},
		{
			"image": operator_img,
			"text": "Leaving root access passwords on a sticky note. Truly, the pinnacle of corporate security protocols."
		},
		{
			"image": operator_img,
			"text": "No wonder this accident could happen. I will log '734' for the Analysis Terminal."
		}
	], self)
	
	DialogSystem.dialog_finished.connect(_on_discovery_finished, CONNECT_ONE_SHOT)

func _on_discovery_finished():
	has_been_read = true
	
	set_process_input(true)



func _show_read_again_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The physical note reads: '734'."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _on_interaction_ended():
	set_process_input(true)
