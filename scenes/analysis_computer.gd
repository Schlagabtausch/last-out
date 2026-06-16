extends Interactable

var unit_l_img = GlobalConstants.PORTRAIT_UNIT_L
var password_ui_scene = preload("res://scenes/password_ui.tscn")
var is_unlocked = false
const SECRET_PASSWORD = "734"

func _ready():
	super._ready()

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		use_object()

func use_object():  
	if is_unlocked:
		if GlobalStats.has_dna:
			DialogSystem.start_dialog([
				{
					"image": unit_l_img,
					"text": "DNA-Sample identified. Master-Key generation available.",
					"choices": [
						{"text": "Generate Master-Key (-1 AP)", "action": "generate_key"},
						{"text": "Cancel", "action": "close"}
					]
				}
			], self)
		else:
			DialogSystem.start_dialog([
				{
					"image": unit_l_img,
					"text": "For creating a Master-Key, security protocols require authenticated biological data (Captain's DNA)."
				}
			], self)
	else:
		var ui_instance = password_ui_scene.instantiate()
		add_child(ui_instance)
		

		var line_edit = ui_instance.get_node("%PasswordInput")
		var btn = ui_instance.get_node("%SubmitButton")
		btn.pressed.connect(func(): 
			check_password(line_edit.text, ui_instance)
		)
		
		var cancel_btn = ui_instance.get_node("%CancelButton")
		cancel_btn.pressed.connect(func(): 
			ui_instance.queue_free()
		)

func check_password(input, dialog_node):
	GlobalStats.current_ap -= 1
	if input == SECRET_PASSWORD:
		is_unlocked = true
		GlobalStats.current_ap -= 1
		dialog_node.queue_free()
		DialogSystem.start_dialog([
			{"image": unit_l_img, "text": "Authorization verified."}
		], self)
		await DialogSystem.dialog_finished
	else:
		dialog_node.hide()
		DialogSystem.start_dialog([
			{"image": unit_l_img, "text": "Alert. Invalid authorization code."}
		], self)
		await DialogSystem.dialog_finished
		if dialog_node:
			dialog_node.popup_centered()

func handle_choice(action):
	if action == "generate_key":
		if GlobalStats.current_ap >= 1:
			GlobalStats.current_ap -= 1
			
			var key_code = "5-3-4-ALPHA"
			DialogSystem.end_dialog()
			
			await get_tree().process_frame
			DialogSystem.start_dialog([
				{"image": unit_l_img, "text": "Generating... Decryption sequence: " + key_code},
				{"image": GlobalConstants.PORTRAIT_OPERATOR, "text": "Received, UNIT-L. Code " + key_code + " noted. I will that sequence ready."}
			], self)
		else:
			DialogSystem.end_dialog()
	elif action == "close":
		DialogSystem.end_dialog()
