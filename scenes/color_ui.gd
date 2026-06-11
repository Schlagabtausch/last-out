extends CanvasLayer

var current_sequence: Array = []

@onready var label = %SequenceLabel
@onready var btn_submit = %ButtonSubmit

func _ready():
	set_player_frozen(true)
	
	# Die 4 Farb-Buttons verbinden
	%ButtonRed.pressed.connect(func(): _add_color("RED"))
	%ButtonBlue.pressed.connect(func(): _add_color("BLUE"))
	%ButtonGreen.pressed.connect(func(): _add_color("GREEN"))
	
	# Löschen-Button verbinden
	%ButtonClear.pressed.connect(_clear_sequence)
	
	_update_label()

func _add_color(color: String):
	if current_sequence.size() < 4:
		current_sequence.append(color)
		_update_label()

func _clear_sequence():
	current_sequence.clear()
	_update_label()

func _update_label():
	if current_sequence.size() == 0:
		label.text = "Warte auf Eingabe..."
	else:
		# Verbindet das Array zu einem schönen Text, z.B. "RED - BLUE"
		label.text = " - ".join(current_sequence)
	
	# Bestätigen-Button nur aktivieren, wenn 4 Farben gewählt wurden
	btn_submit.disabled = current_sequence.size() < 4

func set_player_frozen(is_frozen: bool):
	var player = get_tree().get_first_node_in_group("Player")
	if player and "is_frozen" in player:
		player.is_frozen = is_frozen
