extends Interactable

var is_debris_cleared = false
var has_crowbar = false
var password_ui_scene = preload("res://scenes/password_ui.tscn")

@onready var debris_sprite = $DebrisSprite
@onready var toolbox_sprite = $ToolboxSprite

func _ready():
	super._ready()
	update_visuals()

func update_visuals():
	debris_sprite.visible = !is_debris_cleared
	toolbox_sprite.visible = is_debris_cleared

func use_object():
	if not is_debris_cleared:
		if GlobalStats.current_ap >= 1:
			GlobalStats.current_ap -= 1
			is_debris_cleared = true
			update_visuals()
			DialogSystem.start_dialog([{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Debris removed."}], self)
		else:
			DialogSystem.start_dialog([{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Insufficient AP to clear debris."}], self)
	
	elif not has_crowbar:
		open_password_ui()
	else:
		DialogSystem.start_dialog([{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Toolbox is empty."}], self)

func open_password_ui():
	var ui = password_ui_scene.instantiate()
	add_child(ui)
	ui.password_entered.connect(check_password)

func check_password(input):
	if input == "734":
		has_crowbar = true
		GlobalStats.has_weapon = true
		DialogSystem.start_dialog([{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Access granted. Crowbar acquired."}], self)
	else:
		DialogSystem.start_dialog([{"image": GlobalConstants.PORTRAIT_UNIT_L, "text": "SYSTEM: Invalid code."}], self)
