extends State

var dir

func enter(previous_state_path: String, data := {}) -> void:
	print("RUNNING")
	player.animation_player.play("run")   
	player.rotation_degrees = 0.

func physics_update(delta: float) -> void:
	if stateVersion:
		dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)

		if player.velocity.x < 0: # cours à droite
			player.animation_player.flip_h = true
			player.animation_player.offset.x = 60.
		if player.velocity.x > 0: #cours à gauche
			player.animation_player.flip_h = false
			player.animation_player.offset.x = 0.
		
		if player.is_on_wall_only() and player.velocity.x != 0:
			#player.wall_contact_coyote = player.wall_contact_coyote_time
			#player.velocity.y = player.gravity_wall
			finished.emit(WALL_SLIDING)
		
		if Input.is_action_just_pressed("jump") :
			#if (player.is_on_wall() or player.wall_contact_coyote > 0.) and player.velocity.x != 0:
			#	print("wall/ coyote")
				#player.velocity.y = player.jump_speed
				#player.velocity.x = -player.look_dir_x * player.wall_jump_push_force
			#	finished.emit(WALL_SLIDING)
			if player.is_on_floor():
				finished.emit(JUMPING)
			
		
		elif not player.is_on_floor():
			print("FALLS")
			finished.emit(FALLING)
		elif absf(player.velocity.x) < 70:
			finished.emit(IDLE)
		
		#print("floor ?", player.is_on_floor(), " wall ?", player.is_on_wall())
		player.move_and_slide()
