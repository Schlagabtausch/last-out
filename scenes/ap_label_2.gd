extends Label

func _process(_delta):
	var status_text = "AP: " + str(GlobalStats.current_ap)
	
	text = status_text
