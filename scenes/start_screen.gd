extends Control

@onready var credits_panel = %CreditsPanel

func _ready():
	%BtnCredits.pressed.connect(_on_btn_credits_pressed)

func _on_btn_play_pressed():
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")

func _on_btn_credits_pressed():
	credits_panel.visible = !credits_panel.visible
