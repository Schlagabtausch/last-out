extends Node

var unit_l_img = preload("res://art/portraits/unit_l.png")
var operator_img = preload("res://art/portraits/operator.png")

var current_ap: int = 3:
	set(value):
		current_ap = value		
		if current_ap <= 0:
			call_deferred("trigger_time_loop_reset")
			
func trigger_time_loop_reset():
	
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
	
	DialogSystem.start_dialog(loop_dialog, self)
	DialogSystem.dialog_finished.connect(reset_game, CONNECT_ONE_SHOT)
			
var has_dna: bool = false
var has_weapon: bool = false
var has_crowbar: bool = false
var knows_locker_locked: bool = false
var knows_toolbox_locked: bool = false
var has_cell: bool = false

func reset_game():
	current_ap = 3
	has_weapon = false
	has_dna = false
	has_crowbar = false
	has_cell = false
	knows_locker_locked = false
	knows_toolbox_locked = false
	get_tree().reload_current_scene()
