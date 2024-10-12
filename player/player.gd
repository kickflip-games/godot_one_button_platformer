extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const TERMINAL_VELOCITY = 700

const JUMP_BUTTON = "ui_accept"

@onready var _wallcheck_raycast:RayCast2D = $WallcheckRaycast
@onready var _sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var _jump_sfx:AudioStreamPlayer2D = $JumpAudio


var gravity: int = ProjectSettings.get("physics/2d/default_gravity")

var direction = 1

var _double_jump_charged := false

enum STATE{
	IN_AIR,
	ON_FLOOR,
}

var state:STATE = STATE.ON_FLOOR


func _update_state():
	if is_on_floor():
		state = STATE.ON_FLOOR
	elif not is_zero_approx(velocity.y):
		state = STATE.IN_AIR


func _physics_process(delta: float) -> void:
	

	_update_state()

	if state==STATE.ON_FLOOR:
		_double_jump_charged = true
	elif state==STATE.IN_AIR:
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	
	
	if Input.is_action_just_pressed(JUMP_BUTTON):
		try_jump()
	elif Input.is_action_just_released(JUMP_BUTTON) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
		
	if $WallcheckRaycast.is_colliding():
		_dir_switch()

	if direction:
		velocity.x = direction * SPEED

	move_and_slide()
	


func _dir_switch():
	direction *= -1
	_sprite.flip_h = !_sprite.flip_h
	_wallcheck_raycast.target_position.x *= -1



func try_jump() -> void:
	if is_on_floor():
		_jump_sfx.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		_jump_sfx.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	_jump_sfx.play()


func _draw():
	var p = _wallcheck_raycast.position
	draw_line(p, p + _wallcheck_raycast.target_position, Color.RED)



func _process(delta):
	queue_redraw()
