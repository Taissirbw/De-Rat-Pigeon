extends State

var dir

func enter(previous_state_path: String, data := {}) -> void:
	#state_print("RUNNING")
	player.sounds_loop = 1
	player.audio_player.stream = player.running_sound
	player.audio_player.volume_db= -12
	player.audio_player.pitch_scale = 2
	player.audio_player.play()
	player.particles.show()
	if abs(player.velocity.x) < player.WALK_SPEED:
		player.animation_player.play("walk") 
		player.audio_player.stream_paused =1

	else:  
		print("Run")
		player.animation_player.play("run")
		
		player.audio_player.stream_paused =1
		player.particles.play("run")
	
	# Remet tout bien
	player.rotation_degrees = 0.
	player.animation_player.flip_v = false
	player.animation_player.offset.y = 0.

func physics_update(delta: float) -> void:

	if stateVersion:
		
		if player.shock_state:
			#player.wall_contact_coyote -= delta
			#player.velocity.y += player.gravity * delta
			player.audio_player.playing = false
			finished.emit(SHOCKED)
		
		dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0 and ! player.shock_state:
			player.velocity.x = lerp(player.velocity.x, dir * player.SPEED, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		
		player.look_dir_x = sign(player.velocity.x)
		if player.look_dir_x < 0: # cours à gauche
			player.animation_player.flip_h = true
			#player.animation_player.offset.x = 30.
		if player.look_dir_x > 0: #cours à droite
			player.animation_player.flip_h = false
			#player.animation_player.offset.x = 0.

		if abs(player.velocity.x) < player.WALK_SPEED:
			
			player.animation_player.play("walk") 
		else:  
			player.audio_player.playing = false
			player.particles.play("run")
			player.animation_player.play("run") 

		
		
		if player.is_on_wall_only() and sign(dir) != sign(player.get_wall_normal().x) and player.velocity.x !=0.:
			# state_print("Jumped from wall")
			#player.particles.hide()
			finished.emit(WALL_SLIDING)
		else:
			if player.wall_contact_coyote > 0.:
				player.wall_contact_coyote -= delta
				
		if player.is_on_floor() or player.floor_coyote > 0.:
			if Input.is_action_just_pressed("jump") and ! player.shock_state:
					
				if player.is_on_wall() and sign(dir) != sign(player.get_wall_normal().x) and player.velocity.x !=0.:
					state_print("Jumped from wall+floor")
					player.wall_jump_buffer = player.WALL_JUMP_BUFFER_TIME
					#player.particles.hide()
					finished.emit(WALL_SLIDING)
				else:
					state_print("Jumped from floor")
					player.particles.hide()
					finished.emit(JUMPING)
			elif (absf(player.velocity.x) < player.SPEED/10.) and (dir == 0.):
				player.particles.hide()
				finished.emit(IDLE)
			if player.is_on_floor():
				player.floor_coyote = player.FLOOR_COYOTE_TIME
			else:
				player.floor_coyote -= delta
		else: # Player not on the floor
			state_print("FALLS from RUNNING")
			player.particles.hide()
			finished.emit(FALLING)
		
		
		#state_print("floor ?", player.is_on_floor(), " wall ?", player.is_on_wall())
		player.move_and_slide()
