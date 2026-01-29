extends State


func enter(previous_state_path: String, data := {}) -> void:
	#print("Entered IDLE")
	player.velocity.x = 0.0
	player.animation_player.play("idle")
	player.rotation_degrees = 0. # Remet le rat en mode marche au sol


func physics_update(delta: float) -> void:
	if stateVersion:
		# Décremente le timer coyote
		if player.is_on_wall():
			player.wall_contact_coyote = player.wall_contact_coyote_time
		elif player.wall_contact_coyote > 0.:
			player.wall_contact_coyote -= delta
		#player.move_and_slide()
		
		if player.is_on_floor():
			player.floor_coyote = player.floor_coyote_time
		elif player.floor_coyote > 0.:
			player.floor_coyote = 0

		if player.floor_coyote <= 0:
			finished.emit(FALLING)
		
		# gestion des input, et transition depuis l'état IDLE
		var dir = Input.get_axis("walk_left", "walk_right")
		if Input.is_action_just_pressed("jump"):
			finished.emit(JUMPING)
		elif dir != 0:
			finished.emit(RUNNING)
