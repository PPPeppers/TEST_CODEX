extends Node2D

var buttons: Array[TouchScreenButton] = []
var captions: Array[String] = []

func _ready() -> void:
	_make_button(Vector2(88, 625), "move_left", "<")
	_make_button(Vector2(214, 625), "move_right", ">")
	_make_button(Vector2(1060, 625), "sprint", "B")
	_make_button(Vector2(1180, 585), "jump", "A")

func _make_button(center: Vector2, action_name: String, caption: String) -> void:
	var button := TouchScreenButton.new()
	button.position = center
	button.action = action_name
	button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	button.passby_press = true
	var shape := CircleShape2D.new()
	shape.radius = 47.0
	button.shape = shape
	button.shape_centered = true
	button.shape_visible = false
	add_child(button)
	button.pressed.connect(queue_redraw)
	button.released.connect(queue_redraw)
	buttons.append(button)
	captions.append(caption)
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for index in range(buttons.size()):
		var button := buttons[index]
		var pressed := button.is_pressed()
		var radius := 43.0 if pressed else 47.0
		var fill := Color(0.25, 0.65, 1.0, 0.60) if pressed else Color(0.08, 0.15, 0.25, 0.55)
		draw_circle(button.position, radius, fill)
		draw_arc(button.position, radius, 0, TAU, 48, Color(0.8, 0.9, 1, 0.65), 2, true)
		var caption := captions[index]
		var text_size := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 32)
		draw_string(font, button.position + Vector2(-text_size.x / 2, 11), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)

func disable() -> void:
	hide()
	for action_name in ["move_left", "move_right", "sprint", "jump"]:
		Input.action_release(action_name)
