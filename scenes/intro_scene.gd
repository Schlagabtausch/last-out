extends Control

@onready var line1 = $VBoxContainer/Line1
@onready var line2 = $VBoxContainer/Line2
@onready var line3 = $VBoxContainer/Line3

func _ready():

	var tween = create_tween()
	
	tween.tween_property(line1, "visible_ratio", 1.0, 1.0)
	tween.tween_interval(0.5)
	
	tween.tween_property(line2, "visible_ratio", 1.0, 1.0)
	tween.tween_interval(0.5)
	
	tween.tween_property(line3, "visible_ratio", 1.0, 1.0)
	tween.tween_interval(1.0)
	
	tween.finished.connect(_start_briefing)

func _start_briefing():
	var briefing_data = [
		{
			"image": GlobalConstants.PORTRAIT_COMMANDER,
			"text": "Operator, you have been granted remote access to UNIT-L. Lunaris, Sector 4, is currently trapped in a quantum time-loop - the 'ECHO'. The station's research data on quantum manipulation is classified and critical."
		},
		{
			"image": GlobalConstants.PORTRAIT_COMMANDER,
			"text": "Navigate the bot, bypass the anomalies, and extract the data at all costs. Profit and stability depend on the success of this uplink. Do not let the 'ECHO' influence your mission parameters."
		},
		{
			"image": GlobalConstants.PORTRAIT_COMMANDER,
			"text": "Remember, you are the link. You are the control. The station is replaceable. The data is not."
		},
		{
			"image": GlobalConstants.PORTRAIT_OPERATOR,
			"text": "Understood. Starting remote handshake... UNIT-L is live."
		}
	]
	

	DialogSystem.start_dialog(briefing_data)
	

	await DialogSystem.dialog_finished 
	get_tree().change_scene_to_file("res://scenes/main.tscn")
