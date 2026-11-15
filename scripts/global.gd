extends Node

const SAVE_PATH := "user://awake_gary.cfg"

var best_score: int = 0
var music: AudioStreamPlayer


func _ready() -> void:
	_setup_input()
	_load_best()
	_start_music()


# ---------------------------------------------------------------- input
func _setup_input() -> void:
	_add_action("move_left", [KEY_LEFT, KEY_A])
	_add_action("move_right", [KEY_RIGHT, KEY_D])
	_add_action("jump", [KEY_SPACE, KEY_UP, KEY_W])


func _add_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(action, e)


# ---------------------------------------------------------------- music
func _start_music() -> void:
	var stream = load("res://assets/audio/bgm.mp3")
	if stream == null:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	music = AudioStreamPlayer.new()
	music.stream = stream
	music.volume_db = -12.0
	add_child(music)
	music.play()


# ---------------------------------------------------------------- score
func _load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = int(cfg.get_value("score", "best", 0))


func submit_score(score: int) -> bool:
	if score <= best_score:
		return false
	best_score = score
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best", best_score)
	cfg.save(SAVE_PATH)
	return true


# ---------------------------------------------------------------- helpers
func add_strip(frames: SpriteFrames, anim: StringName, tex: Texture2D, first: int, count: int, cell: Vector2i, fps: float, loop: bool) -> void:
	frames.add_animation(anim)
	frames.set_animation_speed(anim, fps)
	frames.set_animation_loop(anim, loop)
	for i in count:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2((first + i) * cell.x, 0, cell.x, cell.y)
		frames.add_frame(anim, at)


func new_frames() -> SpriteFrames:
	var f := SpriteFrames.new()
	if f.has_animation("default"):
		f.remove_animation("default")
	return f


func make_cat_frames() -> SpriteFrames:
	var f := new_frames()
	var idle: Texture2D = load("res://assets/character/Idle.png")
	var jump: Texture2D = load("res://assets/character/characterJump.png")
	add_strip(f, &"idle", idle, 0, 4, Vector2i(32, 32), 8.0, true)
	add_strip(f, &"squish", jump, 0, 12, Vector2i(64, 64), 16.0, false)
	add_strip(f, &"jump", jump, 12, 7, Vector2i(64, 64), 24.0, false)
	return f


func style_label(l: Label, font_size: int, outline: int = 10) -> void:
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.2))
	l.add_theme_constant_override("outline_size", outline)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
