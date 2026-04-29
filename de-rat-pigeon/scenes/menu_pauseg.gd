extends Control
@onready var menu_pauseg: Control = $"."

func resume():
	get_tree().paused = false
	menu_pauseg.hide()
	
func pause():
	menu_pauseg.show()
	get_tree().paused = true
	
func open_menu():
	if Input.is_action_just_pressed("Pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused == true:
		resume()

func _on_quitter_pressed() -> void:
	get_tree().quit()

func _on_reprendre_pressed() -> void:
	resume()

func _process(delta: float) -> void:
	open_menu()
