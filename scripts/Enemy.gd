extends CharacterBody2D

@export var patrol_distance := 120.0
@export var speed := 85.0
var direction := -1.0
var origin_x := 0.0
var defeated := false
var frozen := false

func _ready() -> void:
	add_to_group("enemies")
	origin_x = global_position.x
	$Contact.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if defeated or frozen:
		return
	var ray_start := global_position + Vector2(direction * 32.0, 0.0)
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_start + Vector2(0, 58), 1)
	var ground_ahead := not get_world_2d().direct_space_state.intersect_ray(query).is_empty()
	if is_on_floor():
		if is_on_wall() or not ground_ahead:
			direction *= -1.0
		elif absf(global_position.x - origin_x) >= patrol_distance:
			if signf(global_position.x - origin_x) == direction:
				direction *= -1.0
	velocity.x = direction * speed
	velocity.y = minf(velocity.y + 1650.0 * delta, 1000.0)
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if defeated or frozen or not body.is_in_group("player"):
		return
	if not body.controls_enabled:
		return
	var enemy_top := global_position.y - 22.0
	if body.velocity.y > 0.0 and body.previous_bottom <= enemy_top + 10.0 and body.global_position.y < global_position.y:
		defeated = true
		body.bounce()
		hide()
		$Contact.set_deferred("monitoring", false)
		queue_free()
	else:
		body.die()

func freeze() -> void:
	frozen = true
	velocity = Vector2.ZERO
