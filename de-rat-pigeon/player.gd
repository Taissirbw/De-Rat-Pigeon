extends CharacterBody2D

@export var speed = 10
@export var jump_speed = -180
@export var gravity = 400
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25


func _physics_process(delta):
	velocity.y += gravity * delta
	var dir = Input.get_axis("walk_left", "walk_right")
	if dir != 0:
		position.x += dir * speed


	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_speed
