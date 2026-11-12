extends Node2D

const PLAYER_SCENE = preload("res://scenes/Player.tscn")
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
const TOUCH_SCRIPT = preload("res://scripts/TouchControls.gd")
const STAGE_WIDTH := 3800

var player: CharacterBody2D
var touch_controls: Node2D
var clear_overlay: ColorRect
var transitioning := false

func _ready() -> void:
	_build_background()
	_build_terrain()
	_build_goal()
	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(120, 530)
	player.defeated.connect(_on_player_defeated)
	add_child(player)
	_spawn_enemy(Vector2(1130, 578), 100)
	_spawn_enemy(Vector2(2090, 578), 110)
	_spawn_enemy(Vector2(2650, 368), 95)
	_build_ui()

func _build_background() -> void:
	var sky := Polygon2D.new()
	sky.polygon = PackedVector2Array([Vector2.ZERO, Vector2(STAGE_WIDTH, 0), Vector2(STAGE_WIDTH, 950), Vector2(0, 950)])
	sky.color = Color("#91d5ef")
	sky.z_index = -20
	add_child(sky)
	for index in range(10):
		var mountain := Polygon2D.new()
		var x := float(index * 450)
		mountain.polygon = PackedVector2Array([Vector2(x - 120, 620), Vector2(x + 180, 260 + (index % 3) * 45), Vector2(x + 510, 620)])
		mountain.color = Color("#6cb5c5")
		mountain.z_index = -15
		add_child(mountain)
	for index in range(12):
		var cloud := Polygon2D.new()
		cloud.position = Vector2(120 + index * 320, 110 + (index % 3) * 36)
		cloud.polygon = PackedVector2Array([Vector2(-50, 15), Vector2(-30, -12), Vector2(-5, -12), Vector2(10, -30), Vector2(40, -25), Vector2(60, 15)])
		cloud.color = Color(1, 1, 1, 0.65)
		cloud.z_index = -10
		add_child(cloud)

func _build_terrain() -> void:
	for rect in [
		Rect2(0, 600, 700, 160), Rect2(850, 600, 780, 160),
		Rect2(1380, 530, 170, 70), Rect2(1510, 460, 180, 140),
		Rect2(1640, 390, 200, 210), Rect2(1800, 600, 2000, 160),
		Rect2(2240, 530, 120, 24), Rect2(2360, 460, 120, 24),
		Rect2(2480, 390, 580, 28), Rect2(3090, 480, 150, 24)
	]:
		_platform(rect)
	_world_label("RUN + JUMP", Vector2(370, 445), 28)
	_world_label("WATCH THE GAP", Vector2(635, 380), 22)
	_world_label("STOMP FROM ABOVE", Vector2(960, 425), 22)
	_world_label("CHOOSE YOUR ROUTE", Vector2(2340, 235), 28)
	_world_label("GOAL", Vector2(3470, 330), 30)

func _platform(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = rect.size / 2
	body.add_child(collision)
	var fill := ColorRect.new()
	fill.size = rect.size
	fill.color = Color("#685443")
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(fill)
	var grass := ColorRect.new()
	grass.size = Vector2(rect.size.x, 12)
	grass.color = Color("#408b55")
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(grass)

func _world_label(text: String, position_value: Vector2, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.position = position_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#203c52"))
	add_child(label)

func _spawn_enemy(position_value: Vector2, distance: float) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.position = position_value
	enemy.patrol_distance = distance
	add_child(enemy)

func _build_goal() -> void:
	var pole := ColorRect.new()
	pole.position = Vector2(3610, 360)
	pole.size = Vector2(10, 240)
	pole.color = Color("#e7edf0")
	pole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pole)
	var flag := Polygon2D.new()
	flag.position = Vector2(3620, 365)
	flag.polygon = PackedVector2Array([Vector2.ZERO, Vector2(105, 35), Vector2(0, 70)])
	flag.color = Color("#ffdf36")
	add_child(flag)
	var goal := Area2D.new()
	goal.name = "Goal"
	goal.position = Vector2(3620, 480)
	goal.collision_layer = 0
	goal.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = Vector2(72, 240)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	goal.add_child(collision)
	goal.body_entered.connect(_on_goal_body_entered)
	add_child(goal)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)
	var header := ColorRect.new()
	header.position = Vector2(24, 20)
	header.size = Vector2(590, 78)
	header.color = Color(0.04, 0.09, 0.16, 0.8)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(header)
	var title := Label.new()
	title.text = "GODOTQUEST / STAGE 01"
	title.position = Vector2(44, 30)
	title.add_theme_font_size_override("font_size", 26)
	canvas.add_child(title)
	var hint := Label.new()
	hint.text = "Hold RUN for longer jumps • Reach the yellow flag"
	hint.position = Vector2(44, 66)
	hint.add_theme_font_size_override("font_size", 17)
	canvas.add_child(hint)
	touch_controls = Node2D.new()
	touch_controls.name = "TouchControls"
	touch_controls.set_script(TOUCH_SCRIPT)
	canvas.add_child(touch_controls)
	clear_overlay = ColorRect.new()
	clear_overlay.size = Vector2(1280, 720)
	clear_overlay.color = Color(0.02, 0.05, 0.10, 0.80)
	clear_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clear_overlay.hide()
	canvas.add_child(clear_overlay)
	var clear_label := Label.new()
	clear_label.text = "클리어! / CLEAR!"
	clear_label.position = Vector2(190, 230)
	clear_label.size = Vector2(900, 170)
	clear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clear_label.add_theme_font_size_override("font_size", 58)
	clear_label.add_theme_color_override("font_color", Color("#ffdf36"))
	clear_overlay.add_child(clear_label)
	var return_label := Label.new()
	return_label.text = "Returning to title in 3 seconds"
	return_label.position = Vector2(290, 420)
	return_label.size = Vector2(700, 50)
	return_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return_label.add_theme_font_size_override("font_size", 25)
	clear_overlay.add_child(return_label)

func _on_player_defeated() -> void:
	if transitioning:
		return
	transitioning = true
	touch_controls.disable()
	call_deferred("_restart_stage")

func _restart_stage() -> void:
	get_tree().reload_current_scene()

func _on_goal_body_entered(body: Node2D) -> void:
	if transitioning or body != player:
		return
	transitioning = true
	player.stop_controls()
	touch_controls.disable()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.freeze()
	clear_overlay.show()
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/TitleScene.tscn")
