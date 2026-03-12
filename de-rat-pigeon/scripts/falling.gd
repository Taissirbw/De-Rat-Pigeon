extends State

func enter(previous_state_path: String, data := {}) -> void:
	#state_print("FALL")
	player.animation_player.play("fall")
	
	# Remet tout bien
	player.rotation_degrees = 0.
	player.animation_player.flip_v = false
	player.animation_player.offset.y = 0.

func physics_update(delta: float) -> void:
	if stateVersion:
		var dir = Input.get_axis("walk_left", "walk_right")
		if !player.shock_state:
			if dir != 0:
				player.velocity.x = lerp(player.velocity.x, dir * player.SPEED, player.acceleration)
			else:
				player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
			if player.velocity.x < 0: # cours à droite
				player.animation_player.flip_h = true
				#0player.animation_player.offset.x = 30.
			if player.velocity.x > 0: #cours à gauche
				player.animation_player.flip_h = false
				#player.animation_player.offset.x = 0. 

			if player.is_on_wall() and player.velocity.x != 0:
				finished.emit(WALL_SLIDING)

			elif player.is_on_floor():
				## Bit of code to play a sound once
				player.audio_player.stream = player.land_on_floor_sound
				player.audio_player.play()
				if player.wall_contact_coyote > 0.:
					player.wall_contact_coyote -= delta
				if Input.is_action_just_pressed("jump") and ! player.shock_state:
					state_print("FALL -> JUMP")
					finished.emit(JUMPING)
				else:
					if abs(player.velocity.x) < 70:
						finished.emit(IDLE)
					else:
						finished.emit(RUNNING)
			
		player.velocity.y += player.GRAVITY * delta
		player.move_and_slide()
