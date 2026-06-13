extends Interactable

var is_empty = false
var correct_code = "9988"

var unit_l_img = preload("res://art/portraits/unit_l.png")
var password_ui_scene = preload("res://scenes/password_ui.tscn")

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
	
	if is_empty or GlobalStats.has_weapon:
		_show_empty_dialog()
	else:
		_open_password_ui()

# --- DIALOGE ---

func _show_empty_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The armory cabinet is wide open. The heavy sidearm is already in my possession."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Authorization accepted. Vault doors unlatched... Heavy sidearm secured. Standard combat protocols are now online."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_wrong_code_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "ACCESS DENIED: Incorrect security override code. Anti-tamper protocols initiated (-1 AP)."
		}
	], self)
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_game_over_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "CRITICAL ERROR: Security counter-measures triggered. Emergency lockdown active. Mission failed."
		}
	], self)
	# Hier keine Reaktivierung des Inputs, da das Spiel vorbei ist und resettet (über dein GlobalStats-System)

# --- UI STEUERUNG ---

func _open_password_ui():
	if password_ui_scene:
		var ui_instance = password_ui_scene.instantiate()
		get_tree().root.add_child(ui_instance)
		
		var line_edit = ui_instance.get_node("%PasswordInput")
		var btn = ui_instance.get_node("%SubmitButton")
		
		# Event verbinden: Wenn der Button gedrückt wird, Passwort prüfen
		btn.pressed.connect(func(): check_password(line_edit.text, ui_instance))
		
		# Sicherheitsnetz: Falls das Fenster anders geschlossen wird, Input reaktivieren
		ui_instance.tree_exited.connect(_on_interaction_ended, CONNECT_ONE_SHOT)
	else:
		print("Fehler: Keine password_ui_scene zugewiesen!")
		_on_interaction_ended()

func check_password(text: String, ui_instance: Node):
	GlobalStats.current_ap -= 1
	var formatted_text = text.strip_edges()
	
	if formatted_text == correct_code:
		# ERFOLG!
		is_empty = true
		GlobalStats.has_weapon = true # Waffe wird ins Inventar gelegt (wird im HUD-Label angezeigt)
		
		# Signal trennen, damit das UI-Schließen nicht fälschlicherweise den Input zu früh freigibt
		if ui_instance.tree_exited.is_connected(_on_interaction_ended):
			ui_instance.tree_exited.disconnect(_on_interaction_ended)
		
		ui_instance.queue_free()
		_show_success_dialog()
	else:

		
		if ui_instance.tree_exited.is_connected(_on_interaction_ended):
			ui_instance.tree_exited.disconnect(_on_interaction_ended)
		
		ui_instance.queue_free()
		
		# Prüfen, ob durch die Bestrafung die AP auf 0 gefallen sind
		if GlobalStats.current_ap <= 0:
			_show_game_over_dialog()
		else:
			_show_wrong_code_dialog()

# --- HILFSFUNKTION ---

func _on_interaction_ended():
	set_process_input(true)
