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
	
	# 1. Zustand: Locker ist bereits offen
	if is_open:
		_show_color_code_dialog()
		
	# 2. Zustand: Locker ist zu, aber wir haben die Brechstange
	elif GlobalStats.has_crowbar:
		_show_crowbar_dialog()
		
	# 3. Zustand: Zu und KEINE Brechstange -> Möglichkeit für Gewaltversuch
	else:
		_show_locked_dialog()

# --- DIALOGE ---

func _show_locked_dialog():
	# NEU: Der Dialog bietet jetzt die Option, Gewalt anzuwenden
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
	# NEU: Der Dialog, der nach dem Fehlschlag angezeigt wird
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
			"text": "Inside the locker is a note. The color code is: RED - BLUE - GREEN - YELLOW."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


# --- AKTIONEN ---

func handle_choice(action: String):
	match action:
		"force_locker":
			try_force_locker()
		"open_locker":
			pry_open_locker()
		"close":
			pass


func try_force_locker():
	# NEU: Logik für den Gewaltversuch
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		
		# ERST JETZT weiß Unit-L / der Spieler, dass der Spind blockiert ist!
		GlobalStats.knows_locker_locked = true
		print("Gewaltversuch fehlgeschlagen! knows_locker_locked ist jetzt TRUE.")
		
		# Signal trennen, um nahtlos den Fehlschlag-Text zu zeigen
		if DialogSystem.dialog_finished.is_connected(_on_interaction_ended):
			DialogSystem.dialog_finished.disconnect(_on_interaction_ended)
		
		await get_tree().process_frame
		_show_force_fail_dialog()
	else:
		print("Nicht genug AP für Gewaltversuch!")
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
		print("Nicht genug AP zum Aufhebeln!")
		_on_interaction_ended()


# --- HILFSFUNKTION ---

func _on_interaction_ended():
	set_process_input(true)
