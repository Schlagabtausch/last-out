extends CanvasLayer

signal password_entered(text)

@onready var input = %PasswordInput
@onready var button = %SubmitButton

func _ready():
	button.pressed.connect(_on_submit_button_pressed)
	input.grab_focus()



func _on_submit_button_pressed() -> void:
	password_entered.emit(input.text)
	queue_free()
