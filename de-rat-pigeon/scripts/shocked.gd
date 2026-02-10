extends State

func enter(previous_state_path: String, data := {}) -> void:
	player.animation_player.pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta: float) -> void:
	
	player.velocity = Vector2(0.,0.)

	if !player.shock_state:
		if player.is_on_floor_only():
			if abs(player.velocity.x) > 0:
				finished.emit(RUNNING)
			else:
				finished.emit(IDLE)
		else:
			finished.emit(FALLING)
