class_name Player extends CharacterBody2D

@export var UseStateMachine = false

@export_category("Player constants")
@export var speed = 800
@export var jump_speed = -1400
@export_category("Player physics")
@export var gravity = 6000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25

@onready var animation_player = $AnimatedSprite2D
@onready var state_machine = $StateMachine
var compteur = 1

func _ready():
	state_machine.init(self, UseStateMachine)

func _physics_process(delta):
	if not UseStateMachine:
		velocity.y += gravity * delta
		var dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
			$AnimatedSprite2D.play("run")
			if velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.offset.x = 60.
			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.offset.x = 0.

		else:
			velocity.x = lerp(velocity.x, 0.0, friction) # ralentissement
		if absf(velocity.x) < 70 :
			$AnimatedSprite2D.play("idle") # Si le joueur n'avance pas, sprite iddle
		move_and_slide()
		
		if compteur==1:
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_speed
				$AnimatedSprite2D.set_animation("jump")
				rotation_degrees = 0.
			if Input.is_action_just_pressed("jump") and is_on_wall():
				velocity.y = jump_speed
				if absf(velocity.y) > 1:
					$AnimatedSprite2D.play("run")
						
				if $AnimatedSprite2D.flip_h :
					rotation_degrees = 90. # Cours sur mur à gauche
				if not $AnimatedSprite2D.flip_h:
					rotation_degrees = -90.
		if is_on_floor():
			rotation_degrees = 0. # Remet le rat en mode marche au sol
			compteur =1 # Reset le compteur de sautg

func _on_tapette_a_souris_body_entered(body: Node2D, source: Area2D) -> void:
	source.activate()
	compteur = 0


func _on_mort_au_rats_body_entered(body: Node2D) -> void:
	$CanvasLayer/ColorRect.visible = true
	# todo : mettre un timer pour désactiver le poison au bout d'un moment
