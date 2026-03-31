extends Control
@onready var jeu =  preload("res://scenes/game.tscn")

func _on_debut_button_down() -> void:
	get_tree().change_scene_to_packed(jeu)
