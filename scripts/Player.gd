extends CharacterBody2D

signal defeated

@export var walk_speed := 260.0
@export var run_speed := 430.0
@export var acceleration := 1250.0
@export var friction := 1600.0
@export var air_acceleration := 550.0
@export var gravity := 1650.0
@export var jump_speed := 580.0
@export var speed_jump_bonus := 95.0

var controls_enabled := true
var dead := false
var previous_bottom := 0.0
var coyote_time := 0.0
var jump_buffer := 0.0
var continuous_move_time := 0.0
var previous_direction := 0.0

func _ready() -> void:
	add_to_group("player")
	previous_bottom = global_position.y + 24.0

func _physics_process(delta: float) -> void:
	previous_bottom = global_position.y + 24.0
	if not controls_enabled:
		velocity = Vector2.ZERO
		return
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0 and direction == previous_direction:
		continuous_move_time += delta
	else:
		continuous_move_time = 0.0
	previous_direction = direction
	var running := Input.is_action_pressed("sprint") or continuous_move_time >= 1.2
	var target_speed := run_speed if running else walk_speed
	if is_on_floor():
		coyote_time = 0.10
	else:
		coyote_time = maxf(0.0, coyote_time - delta)
	jump_buffer = maxf(0.0, jump_buffer - delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.12
	if direction != 0.0:
		var applied_acceleration := acceleration if is_on_floor() else air_acceleration
		var desired_velocity := direction * target_speed
		# 공중에서 같은 방향의 수평 관성을 유지합니다.
		if not is_on_floor() and signf(velocity.x) == direction and absf(velocity.x) > target_speed:
			desired_velocity = velocity.x
		velocity.x = move_toward(velocity.x, desired_velocity, applied_acceleration * delta)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	velocity.y = minf(velocity.y + gravity * delta, 1000.0)
	if jump_buffer > 0.0 and coyote_time > 0.0:
		var speed_ratio := clampf(absf(velocity.x) / run_speed, 0.0, 1.0)
		velocity.y = -(jump_speed + speed_jump_bonus * speed_ratio)
		coyote_time = 0.0
		jump_buffer = 0.0
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45
	move_and_slide()
	if global_position.y > 900.0:
		die()

func bounce() -> void:
	velocity.y = -420.0
	jump_buffer = 0.0

func die() -> void:
	if dead or not controls_enabled:
		return
	dead = true
	controls_enabled = false
	defeated.emit()

func stop_controls() -> void:
	controls_enabled = false
	velocity = Vector2.ZERO
