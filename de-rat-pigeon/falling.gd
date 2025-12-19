extends State

func enter(previous_state_path: String, data := {}) -> void:
	print("FALL")
	player.animation_player.play("fall")

func physics_update(delta: float) -> void:
	if stateVersion:
		var dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		
		if player.is_on_wall() and player.velocity.x != 0:
				if Input.is_action_just_pressed("jump"):
					player.velocity.y = player.jump_speed
					player.velocity.x = -player.look_dir_x * player.wall_jump_push_force
					finished.emit(WALL_SLIDING)
				player.wall_contact_coyote = player.wall_contact_coyote_time
				player.velocity.y = player.gravity_wall
					
		player.velocity.y += player.gravity * delta

		if player.is_on_floor() or player.wall_contact_coyote >0.:
			if player.wall_contact_coyote > 0.:
				if Input.is_action_just_pressed("jump"):
					player.velocity.y = player.jump_speed
					player.velocity.x = -player.look_dir_x * player.wall_jump_push_force
					finished.emit(WALL_SLIDING)
			elif player.is_on_floor():
				
				if Input.is_action_just_pressed("jump"):
					print("FALL -> JUMP")
					finished.emit(JUMPING)
				elif player.velocity.x < 70:
					finished.emit(IDLE)
				else:
					finished.emit(RUNNING)
		player.move_and_slide()
