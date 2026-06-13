extends Control

@onready var credits_text = $CreditsText

# Wie lange soll das Scrollen dauern? (in Sekunden)
@export var scroll_duration: float = 12.0 

func _ready():
	# 1. Setze den Text zu Beginn ganz nach unten, knapp außerhalb des Bildschirms
	var screen_height = get_viewport_rect().size.y
	credits_text.position.y = screen_height
	
	# 2. Erstelle die Scroll-Animation
	var tween = create_tween()
	
	# Ziel-Position: Soweit nach oben, bis der komplette Text aus dem Bild verschwunden ist
	var target_y = -credits_text.size.y - 50 
	
	# Bewege die Y-Position des Textes zum Ziel
	tween.tween_property(credits_text, "position:y", target_y, scroll_duration)
	
	# 3. Wenn die Animation fertig ist, wechsle zum Title Screen
	tween.tween_callback(go_to_title_screen)

func go_to_title_screen():
	# Lade den Titelbildschirm (Passe den Pfad an deine Ordnerstruktur an!)
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

# OPTIONAL: Erlaube dem Spieler, die Credits mit der Interaktions-Taste zu überspringen
func _input(event):
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		go_to_title_screen()
