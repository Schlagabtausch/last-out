extends CanvasLayer    

signal password_entered(text)

@onready var input = %PasswordInput
@onready var button = %SubmitButton

func _ready():
	button.pressed.connect(_on_submit_button_pressed)
	input.call_deferred("grab_focus")   
	set_player_frozen(true)


func _on_submit_button_pressed() -> void:
	password_entered.emit(input.text)
	set_player_frozen(false)
	queue_free()

func set_player_frozen(is_frozen: bool):
	var player = get_tree().get_first_node_in_group("Player")
	if player and "is_frozen" in player:
		player.is_frozen = is_frozen
