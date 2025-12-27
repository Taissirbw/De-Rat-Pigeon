extends State


func enter(previous_state_path: String, data := {}) -> void:
	#print("Entered IDLE")
	player.velocity.x = 0.0
	player.animation_player.play("idle")
	player.rotation_degrees = 0. # Remet le rat en mode marche au sol
	#player.compteur = 1 # Reset le compteur de sautg


func physics_update(delta: float) -> void:
	if stateVersion:
		player.velocity.y += player.gravity * delta
		player.wall_contact_coyote -= delta
		player.move_and_slide()
		
		var dir = Input.get_axis("walk_left", "walk_right")
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		elif dir != 0:
			finished.emit(RUNNING)
