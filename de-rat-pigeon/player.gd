class_name Player extends CharacterBody2D

# Active l'implémentation Machine à etats
@export var UseStateMachine = false
@export var show_wall_debug = false

@export_category("Normal physics")
@export var gravity = 6000
@export_range(0.0, 1.0) var friction = 0.3
@export_range(0.0 , 1.0) var acceleration = 0.1

@export_category("Player constants")
@export var speed = 600
@export var jump_speed_y = -800
@export var jump_speed_x = 400
@export var VariableJumpMultiplier = 0.5
@export var floor_coyote_time:float = 0.05
var floor_coyote:float = 0.
# Pour wall slide
@export_category("Wall physics")
@export var gravity_wall:float = 2000
@export var wall_jump_speed_x: float = 800
@export var wall_jump_speed_y:float = -800

# Lorsque le joueur viens d'attérir sur un mur, 
# il a un petit peu de temps avant de subir la gravité à nouveau.
@export var wall_land_coyote_time = 0.3 
# Pour wall-jump, il faut un saut enregistré + le joueur change de sens
@export var wall_jump_buffer_time = 0.5 # temps durant lequel un saut est enregistré
@export var wall_change_coyote_time = 0.1 # temps durant lequel le changement de dir est valable

@export var wall_contact_coyote_time:float = 0.2 # record last contact with a wall
# apres un wall-jump, le joueur ne peut pas ressauter immédiatement.
@export var wall_jump_lock_time:float= 0.05

var wall_land_coyote:float =0.
var wall_change_coyote:float = 0.
var wall_jump_buffer:float = 0.
var wall_contact_coyote:float = 0.

var wall_jump_lock:float = 0.

var look_dir_x:int = 1

@onready var animation_player = $AnimatedSprite2D

@onready var state_machine = $StateMachine

@onready var state_label = $state_label
@onready var physic_label = $"CanvasLayer/physic_label"
@onready var coyote_label = $CanvasLayer/change_coyote
var compteur = 1


func _ready():
	print("te")
	state_machine.init(self, UseStateMachine)
	physic_label.text = "Velocity X : " + str(velocity.x) + "\n Velocity Y : " + str(velocity.y)

func _physics_process(delta):
	
	# Met à jour l'affichage de la velocité
	physic_label_update()
	
	if show_wall_debug:
		# Permet de visualiser (en utilisant des couleurs) l'état du joueur :
		# Rouge si le joueur est sur le mur, vert si le coyote >0, et jaune si
		# le joueur est sur le mur ET coyote > 0.
		update_shader_coyote() 
		
		
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
				velocity.y = jump_speed_y
				$AnimatedSprite2D.set_animation("jump")
				rotation_degrees = 0.
			if Input.is_action_just_pressed("jump") and is_on_wall():
				velocity.y = jump_speed_y
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
	# todo  : mettre un timer pour désactiver le poison au bout d'un moment

# debug : affiche l'état actuel sous le rat
func _on_state_machine_state_transition() -> void:
	state_label.text = state_machine.current_state.name

# Affichage de la Vélocité pour debug
func physic_label_update():
	coyote_label.text = str(wall_change_coyote)
	physic_label.text = "Velocity X : " + str(int(velocity.x)) + "\n Velocity Y : " + str(int(velocity.y))

func update_shader_coyote():
	animation_player.material.set_shader_parameter("on_wall", is_on_wall())
	animation_player.material.set_shader_parameter("coyote_pos", wall_contact_coyote > 0.)
