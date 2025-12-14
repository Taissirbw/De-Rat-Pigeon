extends CharacterBody2D

@export var speed = 800
@export var jump_speed = -1800
@export var gravity = 6000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25
@onready var camera := $Camera as Camera2D

func _physics_process(delta):
    velocity.y += gravity * delta
    var dir = Input.get_axis("walk_left", "walk_right")
    if dir != 0:
        velocity.x = lerp(velocity.x, dir * speed, acceleration)
        $AnimatedSprite2D.set_animation("run")
    else:
        velocity.x = lerp(velocity.x, 0.0, friction)
        #$AnimatedSprite2D.set_animation("default")

    move_and_slide()
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_speed
        $AnimatedSprite2D.set_animation("jump") # ca ne marche pas
        rotation_degrees = 0.
    if Input.is_action_just_pressed("jump") and is_on_wall():
        velocity.y = jump_speed
        $AnimatedSprite2D.set_animation("run")
        rotation_degrees = 90.
