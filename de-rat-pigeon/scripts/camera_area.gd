extends Area2D

@onready var player: Player = $"../../Player"

@onready var camera_labyrinth: Camera2D = $CameraLabyrinth

var camera_tween:Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_camera_area()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		remove_area_camera()
	
func remove_area_camera():
	var labyrinth_pos = camera_labyrinth.position
	var labyrinth_zoom = camera_labyrinth.zoom
	
	if camera_tween:
		camera_tween.custom_step(99999)
	camera_tween = create_tween()
	camera_tween.tween_property(camera_labyrinth, "zoom", player.camera_2d.zoom, 1.)
	camera_tween.parallel().tween_property(camera_labyrinth, "position", player.camera_2d.global_position, 1.)
	await camera_tween.finished
	
	# Changement de caméra
	camera_labyrinth.set_enabled(false)
	player.camera_2d.set_enabled(true)
	
	# Reinitialise la caméra pour la prochaine fois que le joueur entre dans la zone
	camera_labyrinth.position = labyrinth_pos
	camera_labyrinth.zoom = labyrinth_zoom

func set_camera_area():
	var labyrinth_pos = camera_labyrinth.position
	var labyrinth_zoom = camera_labyrinth.zoom
	
	camera_labyrinth.position = player.camera_2d.global_position
	camera_labyrinth.zoom = player.camera_2d.zoom
	
	camera_labyrinth.set_enabled(true)
	player.camera_2d.set_enabled(false)
	
	if camera_tween:
		camera_tween.custom_step(99999)
	camera_tween = create_tween()
	camera_tween.tween_property(camera_labyrinth, "zoom", labyrinth_zoom, 1.)
	camera_tween.parallel().tween_property(camera_labyrinth, "position", labyrinth_pos, 1.)
