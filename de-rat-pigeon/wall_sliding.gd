extends State



var dir 
var last_wall_dir

func enter(previous_state_path: String, data := {}) -> void:	
	#print("Entered CLIMBING")		
	#player.velocity.y = player.jump_speed
	player.look_dir_x = sign(player.velocity.x)
	#print("CLIMBING : ", player.look_dir_x)
	last_wall_dir = player.look_dir_x
	#if absf(player.velocity.x) > 1:
	player.animation_player.play("run")
	player.animation_player.flip_h = bool(player.look_dir_x)
	player.animation_player.offset.x = 30. * int(player.look_dir_x == -1)
	player.rotation_degrees = -90. * player.look_dir_x
	#if player.velocity.x >0:
		#player.animation_player.flip_h = true
		#player.rotation_degrees = 90. # Cours sur mur à gauche
	#if player.velocity.x < 0:
		#player.animation_player.flip_h = false
		#player.rotation_degrees = -90.

func linear_jump(a, b):
	return Vector2(a*player.wall_jump_speed_x, b*player.wall_jump_speed_y)

func physics_update(delta: float) -> void:
	if stateVersion:
		# Gère les inputs pour déterminer si le joueur va vers le mur
		dir = Input.get_axis("walk_left", "walk_right")
		var previous_dir = player.look_dir_x
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		player.look_dir_x = sign(player.velocity.x)
		
		
		# Le joueur tombe du mur si
		# soit sa vélocité x est nulle (player.look_dir_x == 0)
		# soit sa vélocité y est élevée et le joueur n'est pas sur un mur
		if player.look_dir_x == 0 or (player.velocity.y > 70 and not player.is_on_wall):
			if player.is_on_floor():
				finished.emit(IDLE)
			else:
				finished.emit(FALLING)
				
		# Mets à jour le sens des sprites
		player.animation_player.flip_h = bool(player.look_dir_x < 0)
		player.animation_player.offset.x = 30. * int(player.look_dir_x == -1)
		player.rotation_degrees = -90. * player.look_dir_x
		
		# jsp ce que ça fait
		if player.wall_jump_lock > 0.:
			player.wall_jump_lock -= delta
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration * 0.5)
		
		if player.wall_land_coyote > 0.:
			player.wall_land_coyote -= delta
		
		if player.is_on_floor():
			print("On floor")
			if Input.is_action_just_pressed("jump"):
				finished.emit(JUMPING)
			else:
				if absf(player.velocity.x) > 1:
					finished.emit(RUNNING)
				else:
					finished.emit(IDLE)
			
		# Derniers cas : le joueur reste dans l'état wall sliding
		elif (player.is_on_wall() or player.wall_contact_coyote >0.):
			#print("player.get_wall_normal :", player.get_wall_normal())

			if sign(dir) == sign(player.get_wall_normal().x):
				player.wall_change_coyote = player.wall_change_coyote_time
			else:
				if player.wall_change_coyote > 0.:
					player.wall_change_coyote -= delta
			
			# Stocke le dernier saut
			if Input.is_action_just_pressed("jump"):
				player.wall_jump_buffer = player.wall_jump_buffer_time
			else:
				player.wall_jump_buffer -= delta
			
			# Wall jump
			if player.wall_change_coyote > 0. and player.wall_jump_buffer >0.:
					print("Jump on wall")
					var jump = linear_jump(1.25, 1.)
					
					player.velocity.y = jump.y
					# Repousse vers la direction opposée au mur
					player.velocity.x = -player.look_dir_x * jump.x
					player.wall_jump_lock = player.wall_jump_lock_time
					player.wall_change_coyote = 0.
					player.wall_jump_buffer = 0.
			#elif player.wall_jump_lock > 0.:
			#	player.wall_change_coyote = 0.
			if player.is_on_wall(): # Maj du dernier temps de contact avec un mur
				print("on wall")
				player.wall_contact_coyote = player.wall_contact_coyote_time
				last_wall_dir = player.look_dir_x
			else:
				player.wall_contact_coyote -= delta
			if !player.wall_land_coyote > 0.:
				player.velocity.y += player.gravity_wall * delta
		else:
			player.velocity.y += player.gravity * delta

			
		player.move_and_slide()
		
	
