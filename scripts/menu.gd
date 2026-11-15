extends Control

const HoverButton := preload("res://scripts/hover_button.gd")


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.243, 0.745, 1.0)
	bg.position = Vector2.ZERO
	bg.size = Vector2(1152, 648)
	add_child(bg)

	var sky := TextureRect.new()
	sky.texture = load("res://assets/menu/sky2.jpg")
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.position = Vector2(0, 360)
	sky.size = Vector2(1152, 290)
	add_child(sky)

	var title := Label.new()
	title.text = "AWAKE GARY"
	title.position = Vector2(0, 28)
	title.size = Vector2(1152, 100)
	Global.style_label(title, 84, 18)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Jump from the trees to the clouds to the stars!"
	subtitle.position = Vector2(0, 128)
	subtitle.size = Vector2(1152, 40)
	Global.style_label(subtitle, 28, 8)
	add_child(subtitle)

	var best := Label.new()
	best.text = "Best height: %d" % Global.best_score
	best.position = Vector2(0, 168)
	best.size = Vector2(1152, 36)
	Global.style_label(best, 24, 6)
	add_child(best)

	var cat := AnimatedSprite2D.new()
	cat.sprite_frames = Global.make_cat_frames()
	cat.scale = Vector2(5, 5)
	cat.position = Vector2(576, 300)
	add_child(cat)
	cat.play("idle")
	var tween := create_tween().set_loops()
	tween.tween_property(cat, "position:y", 286.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cat, "position:y", 300.0, 0.6).set_trans(Tween.TRANS_SINE)

	var start := _make_button("START", Vector2(384, 390))
	start.pressed.connect(_on_start_pressed)
	var quit := _make_button("EXIT", Vector2(384, 490))
	quit.pressed.connect(func(): get_tree().quit())
	start.grab_focus()

	var hint := Label.new()
	hint.text = "A / D or Left / Right = move     SPACE = hold to charge, release to jump"
	hint.position = Vector2(0, 600)
	hint.size = Vector2(1152, 30)
	Global.style_label(hint, 20, 6)
	add_child(hint)


func _make_button(text: String, pos: Vector2) -> Button:
	var b := HoverButton.new()
	b.text = text
	b.position = pos
	b.size = Vector2(384, 80)
	b.add_theme_font_size_override("font_size", 36)
	add_child(b)
	return b


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
