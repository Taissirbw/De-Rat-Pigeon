extends State



var dir 
var last_wall_dir

func enter(previous_state_path: String, data := {}) -> void:	
	#state_print("Entered CLIMBING")		
	if previous_state_path != WALL_SLIDING:
		player.sounds_loop = 0
		player.audio_player.stream = player.wall_touch_sound
		player.audio_player.volume_db= -10
		player.audio_player.pitch_scale = 0
		player.audio_player.play()
	
	player.animation_player.play("walk")
	player.particles.play("run")
	player.particles.show()
	
	player.animation_player.flip_h = (player.velocity.y < 5)
	player.particles.flip_h = (player.velocity.y < 5)
	
	player.look_dir_x = sign(player.velocity.x)
	last_wall_dir = player.look_dir_x
	
	player.wall_grip_coyote = player.WALL_GRIP_COYOTE_TIME
	
	if previous_state_path != "Falling":
		player.small_wall_jump_cpt = player.MAX_SMALL_WALL_JUMP
		player.floor_wall_jump_cpt = player.MAX_FLOOR_WALL_JUMP

func linear_jump(a, b):
	return Vector2(a*player.WALL_JUMP_SPEED_X, b*player.WALL_JUMP_SPEED_Y)

func physics_update(delta: float) -> void:
	if stateVersion:
		
		if player.shock_state:
			player.particles.hide()
			player.audio_player.playing = false
			finished.emit(SHOCKED)
		
		# Gère les inputs pour déterminer si le joueur va vers le mur
		dir = Input.get_axis("walk_left", "walk_right")
		var previous_dir = player.look_dir_x
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.SPEED, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		player.look_dir_x = sign(player.velocity.x)

		# Le joueur tombe du mur si
		# soit sa vélocité x est nulle (player.look_dir_x == 0)
		# soit sa vélocité y est élevée et le joueur n'est pas sur un mur
		if player.look_dir_x == 0 or (player.velocity.y > 70 and not player.is_on_wall):
			if player.is_on_floor():
				player.particles.hide()
				player.audio_player.playing = false
				finished.emit(IDLE)
			else:
				player.particles.hide()
				player.audio_player.playing = false
				finished.emit(FALLING)

		# Mets à jour le sens des sprites
		if abs(player.velocity.y) > 5:
			player.animation_player.flip_h = (player.velocity.y > 5) or (last_wall_dir== -1) and not ((player.velocity.y > 5) and (last_wall_dir== -1))
		player.rotation_degrees = -90. * last_wall_dir
		
		



		# jsp ce que ça fait
		if player.wall_jump_lock > 0.:
			player.wall_jump_lock -= delta
			player.velocity.x = lerp(player.velocity.x, dir * player.SPEED, player.acceleration * 0.5)
		
		if player.wall_grip_coyote > 0.:
			player.wall_grip_coyote -= delta
		
		if player.is_on_floor():
			if Input.is_action_just_pressed("jump"):
				player.particles.hide()
				player.audio_player.playing = false
				finished.emit(JUMPING)
			else:
				if player.is_on_wall() and player.floor_wall_jump_cpt > 0:
					state_print("Floor-Wall jump")
					player.velocity.y = player.FLOOR_WALL_JUMP_Y 
					player.floor_wall_jump_cpt = 0
					player.wall_jump_buffer = 0.
				elif absf(player.velocity.x) > 1:
					state_print("to running")
					player.audio_player.playing = false
					finished.emit(RUNNING)
				else:
					player.particles.hide()
					player.audio_player.playing = false
					finished.emit(IDLE)
			
		# Derniers cas : le joueur reste dans l'état wall sliding
		elif (player.is_on_wall_only() or player.wall_contact_coyote >0.):

			if sign(dir) == sign(player.get_wall_normal().x):
				player.wall_change_coyote = player.WALL_CHANGE_COYOTE_TIME
			else:
				if player.wall_change_coyote > 0.:
					player.wall_change_coyote -= delta

			# Stocke le dernier saut
			if Input.is_action_just_pressed("jump"):
				player.wall_jump_buffer = player.WALL_JUMP_BUFFER_TIME
			else:
				player.wall_jump_buffer -= delta
			
			# Wall jump logic :
			if player.wall_jump_buffer > 0.:
				
				# Grand saut vers le mur opposé
				if player.wall_change_coyote > 0.:
						#state_print("Jump on wall")
						var jump = linear_jump(1.25, 1.)
						player.velocity.y = jump.y
						
						# Repousse vers la direction opposée au mur
						player.velocity.x = -player.look_dir_x * jump.x
						# (Re)initialise les compteurs
						player.wall_jump_lock = player.WALL_JUMP_LOCK_TIME
						player.small_wall_jump_cpt = player.MAX_SMALL_WALL_JUMP
						player.floor_wall_jump_cpt = player.MAX_FLOOR_WALL_JUMP
						player.wall_change_coyote = 0.
						player.wall_jump_buffer = 0.
				
				# Petit saut le long du mur
				elif player.small_wall_jump_cpt > 0:
					player.velocity.y = player.SMALL_WALL_JUMP_Y
					
					# Reinitialise les compteurs
					player.small_wall_jump_cpt = 0
					player.wall_jump_buffer = 0.
			
			# Maj du dernier temps de contact avec un mur
			if player.is_on_wall_only(): 
				player.wall_contact_coyote = player.WALL_CONTACT_COYOTE_TIME
				last_wall_dir = player.look_dir_x
			else:
				player.wall_contact_coyote -= delta
			
			## WALL GRIP
			# Empeche le joueur de glisser vers le bas lors de l'atterissage
			if player.wall_grip_coyote > 0. and player.is_on_wall_only():
				player.velocity.y = min(player.velocity.y, 0.)
			# Au dela de ce temps, il glisse le long du mur
			else:
				player.velocity.y += player.GRAVITY_WALL * delta
		else:
			player.wall_change_coyote = 0.
			player.wall_jump_buffer = 0.
			#TODO Fix temporaire : il faudrait décrémenter la vélocité
			player.particles.hide()
			player.audio_player.playing = false
			finished.emit(FALLING)

		# Le moteur physique applique les forces
		player.move_and_slide()
