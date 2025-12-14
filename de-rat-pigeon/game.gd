class_name Game extends Node


@onready var _pause_menu := $InterfaceLayer/pause_menu as PauseMenu


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()
