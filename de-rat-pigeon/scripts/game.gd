class_name Game extends Node
@export_category("Music")
@export var Music:AudioStreamWAV
@export var music_loop =1
#@onready var _pause_menu := $InterfaceLayer/pause_menu as PauseMenu
@onready var ambiant_music: AudioStreamPlayer = $Ambiant_Music

func _ready() -> void:
	ambiant_music.stream = Music
	ambiant_music.volume_db= -15
	ambiant_music.play()
	
func _on_audio_stream_player_2d_finished() -> void:
	if music_loop:
		ambiant_music.play()
	pass # Replace with function body.
