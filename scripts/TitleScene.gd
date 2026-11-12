extends Control

var starting := false

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#101c30")
	background.size = Vector2(1280, 720)
	add_child(background)
	# Optional Korean font: res://fonts/NotoSansKR-Regular.ttf.
	# English remains available without an external font.
	_add_label("고닷퀘스트 / GODOTQUEST", Rect2(140, 160, 1000, 100), 48)
	_add_label("RUN • JUMP • REACH THE FLAG", Rect2(240, 295, 800, 50), 24)
	var start := Button.new()
	start.text = "START"
	start.position = Vector2(490, 410)
	start.size = Vector2(300, 80)
	start.add_theme_font_size_override("font_size", 32)
	start.pressed.connect(_start)
	add_child(start)
	_add_label("A / D or arrows: MOVE    SHIFT / Z: RUN\nSPACE / W / UP: JUMP    Touch controls available", Rect2(180, 550, 920, 90), 22)

func _add_label(text: String, rect: Rect2, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)

func _start() -> void:
	if starting:
		return
	starting = true
	get_tree().change_scene_to_file("res://scenes/Stage1.tscn")
