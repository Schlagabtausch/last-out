extends Node

var unit_l_img = preload("res://art/portraits/unit_l.png")
var operator_img = preload("res://art/portraits/operator.png")

# Zählt, wie oft der normale AP-/Time-Loop-Reset ausgelöst wurde.
# Start: 0
# Nach erstem Reset: 1
# Nach zweitem Reset: 2
var reset_count: int = 0

# Verhindert, dass der Reset mehrfach gleichzeitig gestartet wird,
# falls current_ap mehrfach auf 0 oder darunter gesetzt wird.
var is_resetting: bool = false

var current_ap: int = 3:
	set(value):
		current_ap = value
		if current_ap <= 0:
			call_deferred("trigger_time_loop_reset")


func trigger_time_loop_reset():
	if is_resetting:
		return

	is_resetting = true
	
	var loop_dialog = [
		{
			"image": unit_l_img,
			"text": "Warning: Action capacity depleted. Sync-stability has reached zero percent. I am unable to execute further commands."
		},
		{
			"image": unit_l_img,
			"text": "Local time-impulse detected. The anomaly is collapsing. Initiating hard reset of my temporal coordinates in 3... 2... 1..."
		},
		{
			"image": operator_img,
			"text": "Copy that, UNIT-L. I have saved all the data and passcodes from this run. Brace for timeline reversion. We go again."
		}
	]

	await DialogSystem.dialog_finished
	DialogSystem.start_dialog(loop_dialog, self)
	DialogSystem.dialog_finished.connect(reset_game, CONNECT_ONE_SHOT)


func show_global_wrong_password_dialog(object_to_reconnect: Object, reconnect_function: Callable):
	var wrong_pw_dialog = [
		{
			"image": unit_l_img,
			"text": "Error. Authorization code rejected. Access denied."
		},
		{
			"image": operator_img,
			"text": "Damn it. That wasn't the correct code. I should check my notes or look for more clues."
		}
	]
	
	DialogSystem.start_dialog(wrong_pw_dialog, self)
	DialogSystem.dialog_finished.connect(reconnect_function, CONNECT_ONE_SHOT)


var has_dna: bool = false
var has_weapon: bool = false
var has_crowbar: bool = false
var knows_locker_locked: bool = false
var knows_toolbox_locked: bool = false
var has_cell: bool = false


func reset_full_game():
	current_ap = 3
	reset_count = 0
	is_resetting = false

	has_weapon = false
	has_dna = false
	has_crowbar = false
	has_cell = false
	knows_locker_locked = false
	knows_toolbox_locked = false
	GlobalConstants.is_first_run = true


func reset_game():
	reset_count += 1

	current_ap = 3
	is_resetting = false

	has_weapon = false
	has_dna = false
	has_crowbar = false
	has_cell = false
	knows_locker_locked = false
	knows_toolbox_locked = false

	get_tree().reload_current_scene()
