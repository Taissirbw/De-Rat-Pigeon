extends State

var dir 

func enter(previous_state_path: String, data := {}) -> void:	
	#print("Entered CLIMBING")		
	#player.velocity.y = player.jump_speed
	player.look_dir_x = sign(player.velocity.x)
	#print("CLIMBING : ", player.look_dir_x)
	#if absf(player.velocity.x) > 1:
	player.animation_player.play("run")
	player.animation_player.flip_h = bool(player.look_dir_x)
	player.animation_player.offset.x = 60. * int(player.look_dir_x == -1)
	player.rotation_degrees = -90. * player.look_dir_x
	#if player.velocity.x >0:
		#player.animation_player.flip_h = true
		#player.rotation_degrees = 90. # Cours sur mur à gauche
	#if player.velocity.x < 0:
		#player.animation_player.flip_h = false
		#player.rotation_degrees = -90.

func physics_update(delta: float) -> void:
	if stateVersion:
		dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		player.look_dir_x = sign(player.velocity.x)
		
		if player.look_dir_x == 0:
			if player.is_on_floor():
				finished.emit(IDLE)
			else:
				finished.emit(FALLING)
				
				
		player.animation_player.flip_h = bool(player.look_dir_x < 0)
		player.animation_player.offset.x = 60. * int(player.look_dir_x == -1)
		player.rotation_degrees = -90. * player.look_dir_x
		
		if player.wall_jump_lock > 0.:
			
			player.wall_jump_lock -= delta
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration * 0.5)
		
		if player.is_on_floor():
			if Input.is_action_just_pressed("jump"):
				#player.velocity.y = player.jump_speed
				finished.emit(JUMPING)
			else:
				#player.wall_contact_coyote -= delta
				#player.velocity.y += player.gravity * delta
				if absf(player.velocity.x) > 1:
					finished.emit(RUNNING)
				else:
					finished.emit(IDLE)
			

		elif (player.is_on_wall() or player.wall_contact_coyote >0.):
			if Input.is_action_just_pressed("jump"):
				player.velocity.y = player.jump_speed
				player.velocity.x = -player.look_dir_x * player.wall_jump_push_force
				player.wall_jump_lock = player.wall_jump_lock_time
				
			player.wall_contact_coyote = player.wall_contact_coyote_time
			player.velocity.y += player.gravity_wall * delta
		elif player.velocity.y > 70 or (player.look_dir_x == 0):
			finished.emit(FALLING)

			
		player.move_and_slide()
		
	
