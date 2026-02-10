extends State

var dir

func enter(previous_state_path: String, data := {}) -> void:
	#print("RUNNING")
	if abs(player.velocity.x) < player.walk_speed:
		player.animation_player.play("walk") 
	else:  
		player.animation_player.play("run") 
	
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
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		
		player.look_dir_x = sign(player.velocity.x)
		if player.look_dir_x < 0: # cours à gauche
			player.animation_player.flip_h = true
			#player.animation_player.offset.x = 30.
		if player.look_dir_x > 0: #cours à droite
			player.animation_player.flip_h = false
			#player.animation_player.offset.x = 0.

		if abs(player.velocity.x) < player.walk_speed:
			player.animation_player.play("walk") 
		else:  
			player.animation_player.play("run") 

		
		
		if player.is_on_wall_only() and sign(dir) != sign(player.get_wall_normal().x):
			#player.wall_contact_coyote = player.wall_contact_coyote_time
			#player.velocity.y = player.gravity_wall
			finished.emit(WALL_SLIDING)
		else:
			if player.wall_contact_coyote > 0.:
				player.wall_contact_coyote -= delta
				
		if player.is_on_floor() or player.floor_coyote > 0.:
			if Input.is_action_just_pressed("jump") and ! player.shock_state:
				finished.emit(JUMPING)
			elif (absf(player.velocity.x) < player.speed/10.) and (dir == 0.):
				finished.emit(IDLE)
			if player.is_on_floor():
				player.floor_coyote = player.floor_coyote_time
			else:
				player.floor_coyote -= delta
		else: # Player not on the floor
			print("FALLS from RUNNING")
			finished.emit(FALLING)
		
		
		#print("floor ?", player.is_on_floor(), " wall ?", player.is_on_wall())
		player.move_and_slide()
