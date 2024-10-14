extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const TERMINAL_VELOCITY = 700.0
const WALL_SLIDE_SPEED = 200.0
const WALL_JUMP_VELOCITY = Vector2(-200, -350)
const HOVER_SPEED = 500.0
const HOVER_TIME = 0.125
const JUMP_BUFFER_TIME = 0.1
const GRAVITY_FACTOR = 1.8
const WALL_SLIDE_MOMENTUM_FACTOR = 0.8

const JUMP_ACTION = "jump"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_check: RayCast2D = $WallCheck
@onready var jump_sfx: AudioStreamPlayer2D = $JumpAudio

var gravity: float = ProjectSettings.get("physics/2d/default_gravity") * GRAVITY_FACTOR
var jump_buffer_timer: float = 0.0
var hover_timer: float = 0.0
var direction: int = 1
var wall_slide_velocity: float = 0.0
var has_hovered: bool = false

enum State { RUNNING, JUMPING, FALLING, WALL_SLIDING, HOVERING }
var current_state: State = State.RUNNING

func _physics_process(delta: float) -> void:
	update_timers(delta)
	update_state()
	apply_gravity(delta)
	handle_movement()
	handle_jump()
	move_and_slide()
	check_direction_switch()
	update_animation()

func update_timers(delta: float) -> void:
	jump_buffer_timer = max(jump_buffer_timer - delta, 0)
	hover_timer = max(hover_timer - delta, 0)

func update_state() -> void:
	var previous_state = current_state
	
	if is_on_floor():
		current_state = State.RUNNING
		has_hovered = false
	elif is_on_wall() and velocity.y > 0:
		current_state = State.WALL_SLIDING
		has_hovered = false
		if previous_state != State.WALL_SLIDING:
			wall_slide_velocity = min(0, velocity.y * WALL_SLIDE_MOMENTUM_FACTOR)
	elif hover_timer > 0:
		current_state = State.HOVERING
	elif velocity.y < 0:
		current_state = State.JUMPING
	else:
		current_state = State.FALLING

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if current_state == State.WALL_SLIDING:
			wall_slide_velocity = min(wall_slide_velocity + gravity * delta * 0.1, WALL_SLIDE_SPEED)
			velocity.y = wall_slide_velocity
		elif current_state == State.HOVERING:
			velocity.y = 0
		else:
			velocity.y = min(velocity.y + gravity * delta, TERMINAL_VELOCITY)

func handle_movement() -> void:
	velocity.x = direction * SPEED
	if current_state == State.HOVERING:
		velocity.x = direction * HOVER_SPEED

func handle_jump() -> void:
	if Input.is_action_just_pressed(JUMP_ACTION):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if jump_buffer_timer > 0:
		if is_on_floor():
			jump()
		elif current_state == State.WALL_SLIDING:
			wall_jump()
		elif can_hover():
			hover()
	
	if Input.is_action_just_released(JUMP_ACTION) and velocity.y < 0:
		velocity.y *= 0.5  # Variable jump height

func jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_buffer_timer = 0
	play_jump_sound(1.0)
	CameraManager.shake(0.25, 0.5)

func wall_jump() -> void:
	velocity = WALL_JUMP_VELOCITY
	velocity.x *= -wall_check.scale.x  # Jump away from the wall
	jump_buffer_timer = 0
	switch_direction()
	play_jump_sound(1.2)
	CameraManager.shake(0.25, 0.5)

func hover() -> void:
	if not has_hovered:
		hover_timer = HOVER_TIME
		has_hovered = true
		play_jump_sound(0.8)
		CameraManager.shake(0.25, 1.5)

func can_hover() -> bool:
	return not has_hovered and not is_on_floor() and not is_on_wall()

func play_jump_sound(pitch: float = 1.0) -> void:
	jump_sfx.pitch_scale = pitch
	jump_sfx.play()

func check_direction_switch() -> void:
	if wall_check.is_colliding() and is_on_floor_only():
		switch_direction()
		



func switch_direction() -> void:
	direction *= -1
	wall_check.scale.x *= -1
	sprite.flip_h = direction < 0

func update_animation() -> void:
	return
	#match current_state:
		#State.RUNNING:
			#sprite.play("run")
		#State.JUMPING:
			#sprite.play("jump")
		#State.FALLING:
			#sprite.play("fall")
		#State.WALL_SLIDING:
			#sprite.play("wall_slide")
		#State.HOVERING:
			#sprite.play("hover")
