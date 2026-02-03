extends Node2D

@export var delais_shocks := 1.
@export var duration := 2.

@onready var zap: Area2D = $Zap
@onready var animated_sprite: AnimatedSprite2D = $Zap/AnimatedSprite
@onready var zap_collision: CollisionShape2D = $Zap/ZapCollision
@onready var timer: Timer = $Zap/Timer

var zap_size_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zap_collision.disabled = true
	zap_size_x = zap_collision.shape.size.x
	zap_collision.shape.size.x = 0
	
	timer.wait_time = delais_shocks


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_zap_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.get_shock()

func _on_timer_timeout() -> void:
	animated_sprite.play("shock")
	zap_collision.disabled = false
	
	await animated_sprite.animation_finished
	
	zap_collision.disabled = true

	timer.start()
	
