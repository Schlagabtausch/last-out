extends Interactable

var has_debris = true
var is_unlocked = false

@onready var debris_sprite = $DebrisSprite

var unit_l_img = preload("res://art/portraits/unit_l.png") 
var password_ui_scene = preload("res://scenes/password_ui.tscn")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if debris_sprite:
		debris_sprite.visible = true

func _input(event):
	if get_viewport().gui_get_focus_owner() != null:
		return 

	if player_in_range and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		use_object()

func use_object():
	set_process_input(false)
	
	if has_debris:
		_show_debris_dialog()
	elif is_unlocked: 
		_show_empty_dialog()
	else:
		_show_password_dialog()


func _show_debris_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "This toolbox is buried under heavy debris. Should I clear it?",
			"choices": [
				{"text": "Clear debris (-1 AP)", "action": "clear_debris"},
				{"text": "Leave it", "action": "close"}
			]
		}
	], self)
	
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func handle_choice(action: String):
	match action:
		"clear_debris":
			clear_debris()
		"close":
			pass

func clear_debris():
	if GlobalStats.current_ap >= 1:
		GlobalStats.current_ap -= 1
		has_debris = false
		if debris_sprite:
			debris_sprite.visible = false
	
	_on_interaction_ended()


func _show_password_dialog():
	GlobalStats.knows_toolbox_locked = true
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The debris is cleared, but the lock requires a password."
		}
	], self)
	
	DialogSystem.dialog_finished.connect(_open_password_ui, CONNECT_ONE_SHOT)

func _open_password_ui():
	if password_ui_scene:
		var ui_instance = password_ui_scene.instantiate()
		get_tree().root.add_child(ui_instance)
		
		var line_edit = ui_instance.get_node("%PasswordInput")
		var btn = ui_instance.get_node("%SubmitButton")
		
		btn.pressed.connect(func(): check_password(line_edit.text, ui_instance))
		
		ui_instance.tree_exited.connect(_on_interaction_ended, CONNECT_ONE_SHOT)
	else:
		_on_interaction_ended()

func check_password(text: String, ui_instance: Node):
		
	GlobalStats.current_ap -= 1

	if text == "1234":
		is_unlocked = true
		GlobalStats.has_crowbar = true 
		
		if ui_instance.tree_exited.is_connected(_on_interaction_ended):
			ui_instance.tree_exited.disconnect(_on_interaction_ended)
		
		ui_instance.queue_free()
		_show_success_dialog()
	else:
		if ui_instance.tree_exited.is_connected(_on_interaction_ended):
			ui_instance.tree_exited.disconnect(_on_interaction_ended)
		
		ui_instance.queue_free()
		GlobalStats.show_global_wrong_password_dialog(self, _on_interaction_ended)


func _show_success_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "Password accepted. I've acquired the crowbar."
		}
	], self)
	
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)

func _show_empty_dialog():
	DialogSystem.start_dialog([
		{
			"image": unit_l_img,
			"text": "The toolbox is empty now."
		}
	], self)
	
	DialogSystem.dialog_finished.connect(_on_interaction_ended, CONNECT_ONE_SHOT)


func _on_interaction_ended():
	set_process_input(true)
