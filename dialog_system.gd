extends CanvasLayer

signal dialog_finished

@onready var dialog_box = %DialogBox
@onready var text_label = %DialogText
@onready var portrait = %Portrait
@onready var choice_box = %ChoiceBox
@onready var btn_option1 = %Option1
@onready var btn_option2 = %Option2

var current_dialog = []
var current_line_index = 0
var in_choice_mode = false
var caller_object = null 
var unit_l_img = preload("res://art/portraits/unit_l.png")



func _ready():
	dialog_box.hide()
	choice_box.hide()     
	btn_option1.pressed.connect(_on_option1_pressed)
	btn_option2.pressed.connect(_on_option2_pressed)

func _input(event):
	if not dialog_box.visible:
		return
		
	if not in_choice_mode and event.is_action_pressed("continue_dialogue"):
		var current_line = current_dialog[current_line_index]
		if current_line.has("next"):
			current_line_index = current_line["next"]
		else:
			current_line_index += 1
		_show_current_line()

func start_dialog(dialog_data: Array, caller = null):
	caller_object = caller
	current_dialog = dialog_data
	current_line_index = 0
	in_choice_mode = false
	
	dialog_box.show()
	get_tree().paused = true
	
	await get_tree().process_frame 
	_show_current_line()


func _show_current_line():
	if current_line_index < current_dialog.size():
		var line_data = current_dialog[current_line_index]
		text_label.text = line_data["text"]
		portrait.texture = line_data["image"]
		if line_data.has("choices"):
			_setup_choices(line_data["choices"])
		else:
			choice_box.hide()
			in_choice_mode = false
	else:
		end_dialog()

func _setup_choices(choices: Array):
	in_choice_mode = true
	choice_box.show()
	btn_option1.text = choices[0]["text"]
	btn_option1.show()
	if choices.size() > 1:
		btn_option2.text = choices[1]["text"]
		btn_option2.show()
	else:
		btn_option2.hide()

func end_dialog():
	dialog_box.hide()
	choice_box.hide()
	in_choice_mode = false
	get_tree().paused = false
	current_dialog.clear()
	caller_object = null
	emit_signal("dialog_finished")

func _on_option1_pressed(): _make_choice(0)
func _on_option2_pressed(): _make_choice(1)

func _make_choice(choice_index: int):
	var choices = current_dialog[current_line_index]["choices"]
	var selected_choice = choices[choice_index]
	
	if selected_choice.has("action") and caller_object:
		if caller_object.has_method("handle_choice"):
			caller_object.handle_choice(selected_choice["action"])
	
	choice_box.hide()
	in_choice_mode = false
	
	if selected_choice.has("next"):
		current_line_index = selected_choice["next"]
		_show_current_line()
	else:
		end_dialog()
