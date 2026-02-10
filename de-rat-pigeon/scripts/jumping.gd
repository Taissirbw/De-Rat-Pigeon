extends State

var dir 

func enter(previous_state_path: String, data := {}) -> void:
	#print("JUMPING")

	player.velocity.y = player.jump_speed_y
	dir = Input.get_axis("walk_left", "walk_right")
	player.velocity.x= max( player.jump_speed_x, abs(player.velocity.x))*dir 
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
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)


		if (player.is_on_wall() or player.wall_contact_coyote > 0.) and player.velocity.x !=0.:
			finished.emit(WALL_SLIDING)
		else:
			player.wall_contact_coyote -= delta
			player.velocity.y += player.gravity * delta
			
		if Input.is_action_just_released("jump"):
			player.velocity.y *= player.VariableJumpMultiplier
			
		player.move_and_slide()
		
		if player.velocity.y>=0:
			finished.emit(FALLING)
		
		
		 
		if Input.is_action_just_pressed("jump") and player.compteur == 1 :
			if player.is_on_floor():
				finished.emit(JUMPING)
			elif (player.is_on_wall() or player.wall_contact_coyote >0.) and player.velocity.x != 0:
				print("Jump to wall sliding")
				#player.wall_grip_coyote_time = player.wall_grip_coyote
				finished.emit(WALL_SLIDING)
				
		elif player.is_on_floor():
			if (absf(player.velocity.x) > player.speed/10.) or (dir != 0.):
				finished.emit(RUNNING)
			else:
				finished.emit(IDLE)
			
