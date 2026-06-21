extends AudioStreamPlayer2D

@export var first_track: AudioStream
@export var second_track: AudioStream

# Nach dem zweiten Reset soll der zweite Track laufen.
@export var switch_after_resets: int = 2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var selected_track := first_track

	if GlobalStats.reset_count >= switch_after_resets and second_track != null:
		selected_track = second_track

	if selected_track != null:
		stream = selected_track

	if stream != null:
		play()
