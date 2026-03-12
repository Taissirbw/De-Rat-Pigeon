class_name Player extends CharacterBody2D

@export_category("Debug Tools")
# Active l'implémentation Machine à etats
@export var UseStateMachine = false
# Colore la sprite en fonction de l'état par rapport aux murs
@export var show_wall_debug = false
# Imprime les transitions d'états dans la console.
@export var print_state_transition = false

@export_category("Sounds")
@export var running_sound:AudioStreamWAV
@export var land_on_floor_sound:AudioStreamWAV
@export var wall_touch_sound:AudioStreamWAV
@export var oil_sound:AudioStreamWAV
@export var sounds_loop =0
@export_category("Normal physics")
@export var GRAVITY = 2200
@export_range(0.0, 1.0) var friction = 0.3
@export_range(0.0 , 1.0) var acceleration = 0.1

@export_category("Player constants")
@export var WALK_SPEED = 200
@export var SPEED = 600
@export var JUMP_SPEED_Y = -800
@export var JUMP_SPEED_X = 400
@export var VARIABLE_JUMP_MULTIPLIER = 0.5
@export var FLOOR_COYOTE_TIME:float = 0.05
var floor_coyote:float = 0.
# Pour wall slide
@export_category("Wall physics")
@export var GRAVITY_WALL:float = 2000
@export var WALL_JUMP_SPEED_X: float = 800
@export var WALL_JUMP_SPEED_Y:float = -800

# Petit saut supplémentaire sur les murs
@export var SMALL_WALL_JUMP_Y:float = - 600
@export var MAX_SMALL_WALL_JUMP = 1
var small_wall_jump_cpt = MAX_SMALL_WALL_JUMP

# Permet de ramper sur long d'un mur en partant du sol
@export var FLOOR_WALL_JUMP_Y:float = - 400
@export var MAX_FLOOR_WALL_JUMP = 1
var floor_wall_jump_cpt = MAX_FLOOR_WALL_JUMP


# Lorsque le joueur viens d'attérir sur un mur, 
# il a un petit peu de temps avant de subir la gravité à nouveau.
@export var WALL_GRIP_COYOTE_TIME = 0.3 
# Pour wall-jump, il faut un saut enregistré + le joueur change de sens
@export var WALL_JUMP_BUFFER_TIME = 0.5 # temps durant lequel un saut est enregistré
@export var WALL_CHANGE_COYOTE_TIME = 0.1 # temps durant lequel le changement de dir est valable

@export var WALL_CONTACT_COYOTE_TIME:float = 0.2 # record last contact with a wall
# apres un wall-jump, le joueur ne peut pas ressauter immédiatement.
@export var WALL_JUMP_LOCK_TIME:float= 0.05



var wall_grip_coyote:float =0.
var wall_change_coyote:float = 0.
var wall_jump_buffer:float = 0.
var wall_contact_coyote:float = 0.

var wall_jump_lock:float = 0.

var look_dir_x:int = 1


var shock_state = false
var glissade_state = false
var oil_tween:Tween

var compteur = 1

@onready var shock_timer: Timer = $shockTimer
@onready var oil_timer: Timer = $oilTimer

@onready var animation_player = $AnimatedSprite2D
@onready var particles = $Particles
@onready var shocked_sprite: AnimatedSprite2D = $ShockedSprite
@onready var shock_animation: AnimationPlayer = $ShockAnimation
@onready var oil: Sprite2D = $AnimatedSprite2D/Oil

@onready var state_machine = $StateMachine
@onready var collision_shape = $CollisionShape2D
@onready var state_label = $state_label
@onready var physic_label = $"CanvasLayer/physic_label"
@onready var coyote_label = $CanvasLayer/change_coyote

@onready var camera_2d: Camera2D = $Camera2D
@onready var audio_player = $AudioPlayer

@onready var camera_labyrinth: Camera2D = $"../Level/LabyrinthArea/CameraLabyrinth"





func _ready():
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
		velocity.y += GRAVITY * delta
		var dir = Input.get_axis("walk_left", "walk_right")
		if dir != 0:
			
			velocity.x = lerp(velocity.x, dir * SPEED, acceleration)
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
				velocity.y = JUMP_SPEED_Y
				$AnimatedSprite2D.set_animation("jump")
				rotation_degrees = 0.
			if Input.is_action_just_pressed("jump") and is_on_wall():
				velocity.y = JUMP_SPEED_Y
				if absf(velocity.y) > 1:
					$AnimatedSprite2D.play("run")
						
				if $AnimatedSprite2D.flip_h :
					rotation_degrees = 90. # Cours sur mur à gauche
				if not $AnimatedSprite2D.flip_h:
					rotation_degrees = -90.
		if is_on_floor():
			rotation_degrees = 0. # Remet le rat en mode marche au sol
			compteur =1 # Reset le compteur de sautg

func shock():
	shock_state = true
	# Joue l'animation qui fait clignotter
	shocked_sprite.play('default')
	shock_animation.play("Shock")

	# Shock Timer controle la durée de l'état de choc
	shock_timer.start()
	await shock_timer.timeout
	shock_state = false
	
	shock_animation.play("RESET")
	shocked_sprite.pause()

func glissade():
	# TODO : 
	# 1 - Enregistrer la dir actuelle du joueur (ou à défaut, la vélocité X)
	# 2 - Dans l'état running, empecher la lecture de dir, et à la place, faire glisser
	# 3 - désactiver le saut et le wall sliding.
	sounds_loop = 0
	audio_player.stream = oil_sound
	audio_player.volume_db=-1
	audio_player.pitch_scale=1
	audio_player.play()
	if !glissade_state:
		glissade_state = true
		var buf_speed = SPEED
		var buf_speedwx = WALL_JUMP_SPEED_X
		var buf_speedwy = WALL_JUMP_SPEED_Y
		SPEED /= 3.
		WALL_JUMP_SPEED_X /=3.
		WALL_JUMP_SPEED_Y /=3.
		
		oil.modulate.a = 1.
	
		if oil_tween:
			oil_tween.kill()
		oil_tween = create_tween()
		oil_tween.set_trans(Tween.TRANS_CUBIC)
		oil_tween.set_ease(Tween.EASE_IN)
		oil_tween.tween_property($AnimatedSprite2D/Oil, "modulate:a", 0., oil_timer.wait_time)
		#oil_timer.start()
		await oil_tween.finished
		glissade_state = false
		SPEED = buf_speed
		WALL_JUMP_SPEED_X = buf_speedwx
		WALL_JUMP_SPEED_Y = buf_speedwy
		

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




func _on_audio_player_finished() -> void:
	if sounds_loop:
		audio_player.play()
	pass # Replace with function body.
