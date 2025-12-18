extends State

var dir 

func enter(previous_state_path: String, data := {}) -> void:	
	print("Entered CLIMBING")		
	player.velocity.y = player.jump_speed
	if absf(player.velocity.y) > 1:
		player.animation_player.play("run")
		if player.velocity.x >0:
			player.animation_player.flip_h = true
			player.rotation_degrees = 90. # Cours sur mur à gauche
		if player.velocity.x < 0:
			player.animation_player.flip_h = false
			player.rotation_degrees = -90.

func physics_update(delta: float) -> void:
	if stateVersion:
		player.velocity.x += player.gravity * delta

		if Input.is_action_just_pressed("walk_up"):
			player.velocity.y = lerp(player.velocity.y, 1. * player.gravity, player.acceleration)
		else:
			player.velocity.y += player.gravity * delta
			
		player.move_and_slide()
		
		if player.is_on_wall():
			if Input.is_action_just_pressed("jump"):
				finished.emit(JUMPING)
			elif player.velocity.y > 0:
				finished.emit(FALLING)
		else:
			if player.is_on_floor():
				if absf(player.velocity.x) > 1:
					finished.emit(RUNNING)
				else:
					finished.emit(IDLE)

		
