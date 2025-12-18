extends State

var dir 

func enter(previous_state_path: String, data := {}) -> void:
	print("Entered JUMPING")
	player.rotation_degrees = 0.
	player.velocity.y = player.jump_speed
	
	player.animation_player.play("jump")

func physics_update(delta: float) -> void:
	if stateVersion:
		player.velocity.y += player.gravity * delta
		dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
		player.move_and_slide()
		
		if player.compteur == 1:
			if Input.is_action_just_pressed("jump"):
				finished.emit(JUMPING)
		if player.is_on_wall():
			finished.emit(CLIMBING)
		if player.is_on_floor():
			if absf(player.velocity.x) > 1:
				finished.emit(RUNNING)
			else:
				finished.emit(IDLE)
			
