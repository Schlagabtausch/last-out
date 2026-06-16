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
		"text": "Operator, listen closely. Following a catastrophic containment breach, Lunar Station Sector 4 was fully evacuated. The facility is now trapped in a quantum time-loop."
	},
	{
		"image": GlobalConstants.PORTRAIT_COMMANDER,
		"text": "A single logistics unit, UNIT-L, was left behind during the panic. We have established a faint uplink. You are to take remote control of this robot and navigate the anomalies."
	},
	{
		"image": GlobalConstants.PORTRAIT_COMMANDER,
		"text": "Your objective is to extract the classified quantum research data. The station is a total loss and the personnel are gone. The data, however, is invaluable. Retrieve it at all costs."
	},
	{
		"image": GlobalConstants.PORTRAIT_OPERATOR,
		"text": "Understood, Commander. Initiating remote handshake... Connection established. UNIT-L is online."
	}
]
	

	DialogSystem.start_dialog(briefing_data)
	

	await DialogSystem.dialog_finished 
	get_tree().change_scene_to_file("res://scenes/main.tscn")
