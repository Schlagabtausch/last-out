extends CanvasLayer

var current_sequence: Array = []
var current_slot_index = 0

@onready var slots = [%Slot1, %Slot2, %Slot3, %Slot4]
@onready var btn_submit = %BtnSubmit
@onready var label = %Label

func _ready():
	set_player_frozen(true)
	
	%BtnRed.pressed.connect(func(): _add_color("RED"))
	%BtnBlue.pressed.connect(func(): _add_color("BLUE"))
	%BtnGreen.pressed.connect(func(): _add_color("GREEN"))
	
	%BtnDelete.pressed.connect(_clear_sequence)
	%BtnCancel.pressed.connect(_on_cancel)
	
	_clear_sequence()

func _add_color(color_name: String):
	if current_sequence.size() < 4:
		current_sequence.append(color_name)
		
		match color_name:
			"RED":
				slots[current_slot_index].color = Color(0.8, 0, 0, 1) 
			"BLUE":
				slots[current_slot_index].color = Color(0, 0, 0.8, 1) 
			"GREEN":
				slots[current_slot_index].color = Color(0, 0.5, 0, 1) 
				
		current_slot_index += 1
		_update_submit_button_status()

func _clear_sequence():
	current_sequence.clear()
	current_slot_index = 0
	
	for slot in slots:
		slot.color = Color(0.1, 0.1, 0.1, 1) 
	
	_update_submit_button_status()

func _update_submit_button_status():
	if current_sequence.size() == 4:
		btn_submit.disabled = false
		label.text = "READY TO CONFIRM"
	else:
		btn_submit.disabled = true
		label.text = "AWAITING INPUT..."

func _on_cancel():
	set_player_frozen(false)
	queue_free()

func set_player_frozen(is_frozen: bool):
	var player = get_tree().get_first_node_in_group("Player")
	if player and "is_frozen" in player:
		player.is_frozen = is_frozen
