extends CharacterBody2D

signal died

const SPEED := 340.0
const GROUND_DECEL := 2600.0
const GRAVITY := 1600.0
const MAX_FALL_SPEED := 1400.0
const MIN_JUMP := 520.0
const MAX_JUMP := 900.0
const MAX_CHARGE_TIME := 0.55
const WORLD_WIDTH := 1152.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var charging := false
var charge := 0.0
var dead := false
var has_jumped := false
var floor_grace := 0.0


func _ready() -> void:
	floor_snap_length = 8.0
	sprite.sprite_frames = Global.make_cat_frames()
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	if dead:
		return

	velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	if is_on_floor():
		floor_grace = 0.08
	else:
		floor_grace = maxf(0.0, floor_grace - delta)

	if floor_grace > 0.0:
		if not charging and Input.is_action_pressed("jump"):
			charging = true
			charge = 0.0
		if charging:
			if Input.is_action_pressed("jump"):
				charge = minf(charge + delta, MAX_CHARGE_TIME)
			else:
				_do_jump()
	else:
		charging = false

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = dir * SPEED
		sprite.flip_h = dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, GROUND_DECEL * delta)

	move_and_slide()

	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var col := c.get_collider()
		if col == null:
			continue
		var kind: Variant = col.get("kind")
		if kind is int and kind == 1:
			die()
			return
		if c.get_normal().y < -0.7 and col.has_method("on_landed"):
			col.on_landed()

	global_position.x = wrapf(global_position.x, -30.0, WORLD_WIDTH + 30.0)

	_update_animation()


func _do_jump() -> void:
	var ratio := clampf(charge / MAX_CHARGE_TIME, 0.0, 1.0)
	velocity.y = -lerpf(MIN_JUMP, MAX_JUMP, ratio)
	charging = false
	charge = 0.0
	floor_grace = 0.0
	has_jumped = true
	sprite.play("jump")


func _update_animation() -> void:
	if charging:
		var ratio := clampf(charge / MAX_CHARGE_TIME, 0.0, 1.0)
		sprite.animation = "squish"
		sprite.frame = int(ratio * 11.0)
		sprite.pause()
	elif floor_grace <= 0.0:
		if sprite.animation != "jump":
			sprite.play("jump")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")


func die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	sprite.pause()
	sprite.modulate = Color(1.0, 0.45, 0.45)
	died.emit()
