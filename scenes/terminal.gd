extends Interactable

var has_been_interacted = false


func _ready():
	super._ready()

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		use_object()
	

func use_object():
	if has_been_interacted:
		DialogSystem.start_dialog([
			{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Locker is empty."}
		])
	else:
		var dialog_content = [
			{
				"image": GlobalConstants.PORTRAIT_UNIT_L,
				"text": "SYSTEM: Locker found. Attempt breach? Cost: 1 AP.",
				"choices": [
					{"text": "Take Sample (-1 AP)", "action": "make_action"},
					{"text": "Cancel", "action": "close"}
				]
			}
		]
		DialogSystem.start_dialog(dialog_content, self)


func handle_choice(action):
	if action == "make_action":
		if GlobalStats.current_ap >= 1:
			GlobalStats.current_ap -= 1
			has_been_interacted = true
			DialogSystem.end_dialog()
		else:
			pass
	elif action == "close":
		DialogSystem.end_dialog()
