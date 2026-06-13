extends Label

func _process(_delta):

	var status_text = ""
	
	if GlobalStats.has_dna:
		status_text += "[Captain's DNA]"
		
	if GlobalStats.has_crowbar:
		status_text += "[Crowbar]"
		
	if GlobalStats.has_cell:
		status_text += "[Energy Cell]"
		
	if GlobalStats.has_weapon: 
		status_text += "[Gun]"
	
	text = status_text
