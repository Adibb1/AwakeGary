extends StaticBody2D
## Cloud platform (art from the nabil branch).
## WHITE cloud: safe, but melts away shortly after Gary lands on it.
## BLACK cloud: deadly on touch.

enum Kind { WHITE, BLACK }

var kind: int = Kind.WHITE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

var _touched := false


func _ready() -> void:
	add_to_group("platforms")
	sprite.sprite_frames = _make_frames()
	sprite.animation_finished.connect(_on_animation_finished)

	if kind == Kind.BLACK:
		sprite.play("black")
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	else:
		sprite.play("white")
		hitbox.set_deferred("monitoring", false)

	sprite.frame = randi() % sprite.sprite_frames.get_frame_count(sprite.animation)
	sprite.flip_h = randf() < 0.5


func _make_frames() -> SpriteFrames:
	var f: SpriteFrames = Global.new_frames()
	var white: Texture2D = load("res://assets/clouds/Default.png")
	var black: Texture2D = load("res://assets/clouds/BlackCloud.png")
	var vanish: Texture2D = load("res://assets/clouds/Disappear.png")
	Global.add_strip(f, &"white", white, 0, 5, Vector2i(32, 32), 5.0, true)
	Global.add_strip(f, &"black", black, 0, 7, Vector2i(32, 32), 8.0, true)
	Global.add_strip(f, &"disappear", vanish, 0, 8, Vector2i(32, 32), 9.0, false)
	return f

func on_landed() -> void:
	if kind == Kind.BLACK or _touched:
		return
	_touched = true
	sprite.play("disappear")
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = 0.8
	t.timeout.connect(func(): shape.set_deferred("disabled", true))
	add_child(t)
	t.start()


func _on_animation_finished() -> void:
	if sprite.animation == &"disappear":
		queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")
