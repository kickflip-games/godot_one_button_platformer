extends Node2D

@onready var PlayerPhantomCamera2d =$PlayerPhantomCamera2D
@onready var CameraShaker = $PlayerPhantomCamera2D/ShakerComponent2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await SceneManager.scene_loaded
		# Find the player node
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0:
		PlayerPhantomCamera2d.follow_target = player[0]
	else:
		push_warning("CameraManager: No player found in the 'Player' group")


func shake(duration:float, intensity:float):
	CameraShaker.stop_shake()
	CameraShaker.duration = duration
	CameraShaker.intensity = intensity
	if !CameraShaker.is_playing:
		CameraShaker.play_shake()
