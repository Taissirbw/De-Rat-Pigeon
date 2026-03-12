extends State

var dir 

func enter(previous_state_path: String, data := {}) -> void:
	#state_print("JUMPING")
	player.audio_player.playing = false
	player.velocity.y = player.JUMP_SPEED_Y
	dir = Input.get_axis("walk_left", "walk_right")
	player.velocity.x = max( player.JUMP_SPEED_X, abs(player.velocity.x))*dir 
	player.animation_player.play("jump")

	# Remet tout bien
	player.rotation_degrees = 0.
	player.animation_player.flip_v = false
	player.animation_player.offset.y = 0.

func physics_update(delta: float) -> void:
	if stateVersion:
		
		if player.shock_state:
			#player.wall_contact_coyote -= delta
			#player.velocity.y += player.gravity * delta
			finished.emit(SHOCKED)
		
		dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0 and ! player.shock_state:
			player.velocity.x = lerp(player.velocity.x, dir * player.SPEED, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)


		if (player.is_on_wall_only() or player.wall_contact_coyote > 0.) and player.velocity.x !=0.:
			state_print("Wall slide from jump 1/2: " + str(player.velocity.y))
			player.velocity.y = max(player.velocity.y, player.WALL_JUMP_SPEED_Y/2.)
			state_print("Wall slide from jump 2/2: " + str(player.velocity.y))
			finished.emit(WALL_SLIDING)
		else:
			player.wall_contact_coyote -= delta
			player.velocity.y += player.GRAVITY * delta
			
		if Input.is_action_just_released("jump"):
			player.velocity.y *= player.VARIABLE_JUMP_MULTIPLIER
			
		player.move_and_slide()
		
		if player.velocity.y>=0:
			finished.emit(FALLING)
		
		
		 
		if Input.is_action_just_pressed("jump") and player.compteur == 1 :
			if player.is_on_floor():
				state_print("Jumping from floor")
				finished.emit(JUMPING)
			elif (player.is_on_wall_only() or player.wall_contact_coyote >0.) and player.velocity.x != 0:
				state_print("Jump to wall sliding")
				#player.wall_grip_coyote_time = player.wall_grip_coyote
				finished.emit(WALL_SLIDING)
				
		elif player.is_on_floor():
			if (absf(player.velocity.x) > player.SPEED/10.) or (dir != 0.):
				finished.emit(RUNNING)
			else:
				finished.emit(IDLE)
			
