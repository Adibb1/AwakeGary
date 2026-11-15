extends Node2D

const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const CLOUD_SCENE := preload("res://scenes/Cloud.tscn")
const TREE_SCENE := preload("res://scenes/Tree.tscn")
const HoverButton := preload("res://scripts/hover_button.gd")
const SkyBackground := preload("res://scripts/sky_background.gd")

const VIEW_W := 1152.0
const VIEW_H := 648.0
const START_CAM_Y := -230.0
const X_MIN := 110.0
const X_MAX := 1042.0
const FEET_OFFSET := 40.0

const DIFFICULTY_HEIGHT := 8000.0
const GAP_MIN_START := 95.0
const GAP_MIN_END := 130.0
const GAP_MAX_START := 150.0
const GAP_MAX_END := 200.0
const CHAIN_STEP_X := 280.0
const BLACK_CHANCE_MIN := 0.25
const BLACK_CHANCE_MAX := 0.6
const BLACK_START_HEIGHT := 200.0

var player: CharacterBody2D
var camera: Camera2D
var platforms_root: Node2D
var sky: Control

var score_label: Label
var hint_label: Label
var over_layer: CanvasLayer
var over_score_label: Label
var over_best_label: Label
var restart_button: Button

var next_y := -140.0
var chain_x := VIEW_W * 0.5
var cam_target_y := START_CAM_Y
var best_height := 0.0
var score := 0
var game_over := false
var over_delay := -1.0


func _ready() -> void:
	randomize()
	_build_sky()
	_build_world()
	_build_ui()

	camera = Camera2D.new()
	camera.position = Vector2(VIEW_W * 0.5, START_CAM_Y)
	add_child(camera)
	camera.make_current()

	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(VIEW_W * 0.5, -FEET_OFFSET - 1.0)
	player.z_index = 2
	player.died.connect(_on_player_died)
	add_child(player)

	_maintain_platforms()


func _build_sky() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	sky = SkyBackground.new()
	layer.add_child(sky)


func _build_world() -> void:
	platforms_root = Node2D.new()
	platforms_root.name = "Platforms"
	add_child(platforms_root)

	var ground := StaticBody2D.new()
	ground.name = "Ground"
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(4000, 200)
	cs.shape = rect
	cs.position = Vector2(VIEW_W * 0.5, 100)
	ground.add_child(cs)

	var grass := ColorRect.new()
	grass.color = Color(0.33, 0.74, 0.30)
	grass.position = Vector2(-1200, 0)
	grass.size = Vector2(4000, 26)
	ground.add_child(grass)
	var dirt := ColorRect.new()
	dirt.color = Color(0.45, 0.30, 0.18)
	dirt.position = Vector2(-1200, 26)
	dirt.size = Vector2(4000, 400)
	ground.add_child(dirt)
	add_child(ground)

	var start_tree := TREE_SCENE.instantiate()
	var tree_bottom := 120.0
	for node in start_tree.find_children("*", "Sprite2D", true, false):
		var spr := node as Sprite2D
		if spr != null and spr.texture != null:
			var h := spr.texture.get_height() * spr.scale.y
			tree_bottom = spr.position.y + (h * 0.5 if spr.centered else h)
			break
	start_tree.position = Vector2(VIEW_W * 0.5 + 200.0, -130)
	platforms_root.add_child(start_tree)

	next_y = start_tree.position.y - 20.0


func _build_ui() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 5
	add_child(hud)

	score_label = Label.new()
	score_label.text = "Height: 0"
	score_label.position = Vector2(24, 14)
	score_label.size = Vector2(400, 50)
	Global.style_label(score_label, 36, 10)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hud.add_child(score_label)

	var best_label := Label.new()
	best_label.text = "Best: %d" % Global.best_score
	best_label.position = Vector2(24, 60)
	best_label.size = Vector2(400, 36)
	Global.style_label(best_label, 24, 8)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hud.add_child(best_label)

	hint_label = Label.new()
	hint_label.text = "A / D or Left / Right = move     Hold SPACE to charge, release to jump     ESC = menu"
	hint_label.position = Vector2(0, 590)
	hint_label.size = Vector2(VIEW_W, 40)
	Global.style_label(hint_label, 22, 8)
	hud.add_child(hint_label)

	over_layer = CanvasLayer.new()
	over_layer.layer = 10
	over_layer.visible = false
	add_child(over_layer)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.position = Vector2.ZERO
	dim.size = Vector2(VIEW_W, VIEW_H)
	over_layer.add_child(dim)

	var title := Label.new()
	title.text = "GAME OVER"
	title.position = Vector2(0, 90)
	title.size = Vector2(VIEW_W, 100)
	Global.style_label(title, 84, 18)
	over_layer.add_child(title)

	over_score_label = Label.new()
	over_score_label.position = Vector2(0, 215)
	over_score_label.size = Vector2(VIEW_W, 50)
	Global.style_label(over_score_label, 38, 10)
	over_layer.add_child(over_score_label)

	over_best_label = Label.new()
	over_best_label.position = Vector2(0, 268)
	over_best_label.size = Vector2(VIEW_W, 44)
	Global.style_label(over_best_label, 30, 8)
	over_layer.add_child(over_best_label)

	restart_button = _make_button("RESTART", Vector2(384, 350))
	restart_button.pressed.connect(func(): get_tree().reload_current_scene())
	var menu_button := _make_button("MENU", Vector2(384, 450))
	menu_button.pressed.connect(_go_menu)


func _make_button(text: String, pos: Vector2) -> Button:
	var b := HoverButton.new()
	b.text = text
	b.position = pos
	b.size = Vector2(384, 80)
	b.add_theme_font_size_override("font_size", 36)
	over_layer.add_child(b)
	return b


func _go_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func _process(delta: float) -> void:
	if not game_over:
		var target := player.global_position.y - 80.0
		if target < cam_target_y:
			cam_target_y = target

		var h := -(player.global_position.y + FEET_OFFSET)
		if h > best_height:
			best_height = h
			score = int(best_height / 10.0)
			score_label.text = "Height: %d" % score

		if player.has_jumped and hint_label.visible:
			hint_label.visible = false

		if player.global_position.y > camera.position.y + VIEW_H * 0.5 + 50.0:
			player.die()
	elif over_delay > 0.0:
		over_delay -= delta
		if over_delay <= 0.0:
			over_layer.visible = true
			restart_button.grab_focus()

	camera.position.y = lerpf(camera.position.y, cam_target_y, clampf(delta * 8.0, 0.0, 1.0))
	sky.set("altitude", maxf(0.0, -camera.position.y + START_CAM_Y))
	_maintain_platforms()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_go_menu()
		elif event.keycode == KEY_R and game_over:
			get_tree().reload_current_scene()


func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	var is_new_best := Global.submit_score(score)
	over_score_label.text = "Height: %d" % score
	if is_new_best:
		over_best_label.text = "NEW BEST!"
	else:
		over_best_label.text = "Best: %d" % Global.best_score
	over_delay = 0.6


func _maintain_platforms() -> void:
	var top := camera.position.y - VIEW_H * 0.5 - 300.0
	while next_y > top:
		_spawn_row()

	var bottom := camera.position.y + VIEW_H * 0.5 + 250.0
	for child in platforms_root.get_children():
		var p := child as Node2D
		if p != null and p.global_position.y > bottom:
			p.queue_free()


func _spawn_row() -> void:
	var prev_x := chain_x
	var prev_y := next_y
	var altitude := maxf(0.0, -next_y)
	var diff := clampf(altitude / DIFFICULTY_HEIGHT, 0.0, 1.0)

	var gap := randf_range(lerpf(GAP_MIN_START, GAP_MIN_END, diff), lerpf(GAP_MAX_START, GAP_MAX_END, diff))
	next_y -= gap
	chain_x = clampf(chain_x + randf_range(-CHAIN_STEP_X, CHAIN_STEP_X), X_MIN, X_MAX)

	_spawn_cloud(chain_x, next_y, 0)

	var black_chance := clampf(0.12 + altitude / 14000.0, BLACK_CHANCE_MIN, BLACK_CHANCE_MAX)
	if altitude > BLACK_START_HEIGHT and randf() < black_chance:
		var jump_mid_x := (prev_x + chain_x) * 0.5
		var side := -1.0 if jump_mid_x > VIEW_W * 0.5 else 1.0
		var obs_x := clampf(jump_mid_x + side * randf_range(240.0, 380.0), X_MIN, X_MAX)
		if absf(obs_x - jump_mid_x) >= 190.0:
			_spawn_cloud(obs_x, prev_y - gap * 0.5, 1)


func _spawn_cloud(x: float, y: float, kind: int) -> void:
	var p: Node2D = CLOUD_SCENE.instantiate()
	p.set("kind", kind)
	p.position = Vector2(x, y)
	platforms_root.add_child(p)
