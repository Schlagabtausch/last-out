extends Interactable

var unit_l_img = GlobalConstants.PORTRAIT_UNIT_L
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
		var input_dialog = AcceptDialog.new()
		input_dialog.dialog_text = "Enter Authorization Code:"
		var line_edit = LineEdit.new()
		line_edit.secret = true
		input_dialog.add_child(line_edit)
		input_dialog.confirmed.connect(func(): check_password(line_edit.text, input_dialog))
		add_child(input_dialog)
		input_dialog.popup_centered()

func check_password(input, dialog_node):
	if input == SECRET_PASSWORD:
		is_unlocked = true
		GlobalStats.current_ap -= 1
		dialog_node.queue_free()
		DialogSystem.start_dialog([
			{"image": unit_l_img, "text": "Authorization verified."}
		], self)
		await DialogSystem.dialog_finished
		use_object()
	else:
		dialog_node.hide()
		DialogSystem.start_dialog([
			{"image": unit_l_img, "text": "Alert. Invalid authorization code. Security lockout temporary active."}
		], self)
		await DialogSystem.dialog_finished
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
