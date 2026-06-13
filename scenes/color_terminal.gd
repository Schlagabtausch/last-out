extends Interactable

var cell_inserted = false
var is_solved = false

var unit_l_img = preload("res://art/portraits/unit_l.png")
var color_ui_scene = preload("res://scenes/ColorUI.tscn")

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
	
	if is_solved:
		_show_already_solved_dialog()
		
	elif cell_inserted:
		_open_color_ui()
		
	elif GlobalStats.has_cell:
		_show_insert_cell_dialog()
		
	else:
		_show_no_power_dialog()

# --- DIALOGE ---

func _show_no_power_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "This terminal is offline. It requires a standard auxiliary energy cell to boot up."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_insert_cell_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The terminal is offline, but I can detect the energy cell in our inventory. Plug it in?",
			"choices": [
				{"text": "Insert Energy Cell (-1 AP)", "action": "insert_cell"},
				{"text": "Leave it", "action": "close"}
			]
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_power_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Energy cell connected. Terminal online. Input sequence required."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_already_solved_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The terminal is unlocked. The weapon override code is 9988."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_correct_code_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Sequence accepted. Accessing armory mainframe... The weapon override code is: 9988. I recommend making a note of this."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_game_over_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "CRITICAL ERROR: Action Points depleted. System shutting down..."
		}
	], self)


func handle_choice(action: String):
	match action:
		"insert_cell":
			insert_cell()
		"close":
			pass

func insert_cell():
	GlobalStats.has_cell = false
	GlobalStats.current_ap -= 1
	cell_inserted = true

	if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
		DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
	await get_tree().process_frame
	_show_power_success_dialog()



func _open_color_ui():
	if color_ui_scene:
		var ui_instance = color_ui_scene.instantiate()
		get_tree().root.add_child(ui_instance)
		
		var btn = ui_instance.get_node("%BtnSubmit")
		
		btn.pressed.connect(func(): check_color_code(ui_instance.current_sequence, ui_instance))
		
		ui_instance.tree_exited.connect(_on_interaction_ended, CONNECT_ONE_SHOT)
	else:
		_on_interaction_ended()

func check_color_code(sequence: Array, ui_instance: Node):
	if GlobalStats.current_ap < 1:
		return
		
	GlobalStats.current_ap -= 1

	if sequence == ["RED", "BLUE", "GREEN", "BLUE"]:
		is_solved = true
		
		if ui_instance.tree_exited.is_connected(_on_interaction_ended):
			ui_instance.tree_exited.disconnect(_on_interaction_ended)
		
		ui_instance.queue_free()
		_show_correct_code_dialog()
	else:
		ui_instance._clear_sequence() 
		
		if GlobalStats.current_ap <= 0:
			if ui_instance.tree_exited.is_connected(_on_interaction_ended):
				ui_instance.tree_exited.disconnect(_on_interaction_ended)
			ui_instance.queue_free()
			_show_game_over_dialog()


func _on_interaction_ended():
	set_process_input(true)
