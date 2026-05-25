extends Node

var current_ap: int = 3:
	set(value):
		current_ap = value		
		if current_ap <= 0:
			call_deferred("reset_game")
			
			
var has_dna: bool = false
var has_weapon: bool = false

func reset_game():
	await DialogSystem.dialog_finished
	current_ap = 3
	has_weapon = false
	get_tree().reload_current_scene()
