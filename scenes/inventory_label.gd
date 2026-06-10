extends Label

func _process(_delta):

	var status_text = ""
	
	if GlobalStats.has_dna:
		status_text += "[Captain's DNA]"
		
	if GlobalStats.has_crowbar:
		status_text += "[Crowbar]"
	
	text = status_text
