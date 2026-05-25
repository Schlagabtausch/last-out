extends Node

var current_ap: int = 3:
	set(value):
		current_ap = value
		print("AP changed to: ", current_ap)
		
		if current_ap <= 0:
			print("No more energy! Reset...")
			reset_game()

var has_dna: bool = false
var has_weapon: bool = false

func reset_game():
	current_ap = 3
	has_weapon = false
	get_tree().reload_current_scene()
