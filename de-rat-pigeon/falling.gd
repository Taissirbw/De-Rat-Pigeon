extends State

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.play("fall")

func physics_update(delta: float) -> void:
	if stateVersion:
		var dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			player.velocity.x = lerp(player.velocity.x, dir * player.speed, player.acceleration)
		else:
			player.velocity.x = lerp(player.velocity.x, 0.0, player.friction)
			
		player.velocity.y += player.gravity * delta
		player.move_and_slide()

		if player.is_on_floor():
			if is_equal_approx(dir, 0.0):
				finished.emit(IDLE)
			else:
				finished.emit(RUNNING)
