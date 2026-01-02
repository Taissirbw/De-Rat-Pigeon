extends Area2D

var camera: Camera2D
var cameraShakeNoise : FastNoiseLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_node("/root/game/Player/Camera2D")
	cameraShakeNoise = FastNoiseLite.new() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activate():
	
	# Tween : fonction variant avec le temps pour animer des paramètres.
	# Ici, le premier tween module la valeur de la couleur du Sprite2D
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Sprite2D, "scale", Vector2(1,1), 0.25)
	#tween.tween_property($Sprite2D, "modulate:v", 0., 0.2) #Valeur à 0 -> sprite noire
	#tween.tween_property($Sprite2D, "modulate:v", 1.0, 0.1) #Valeur à 1 -> sprite normale
	
	# Un deuxième tween pour faire screenshake la caméra
	# D'après le tuto https://www.youtube.com/watch?v=QfojEwv7iRk
	var cameraTween = create_tween()
	cameraTween.tween_method(camera_shake, 20., 1., 0.3)

func camera_shake(intensity:float):
	# L'offset varie en fonction du temps et d'un bruit aléatoire
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera.offset.x = cameraOffset
	camera.offset.y = cameraOffset
