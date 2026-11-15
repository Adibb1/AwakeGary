extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const MIN_JUMP_VELOCITY = -350.0  # Jump height on a quick tap
const MAX_JUMP_VELOCITY = -750.0  # Jump height at full charge
const MAX_CHARGE_TIME = 0.6     # Seconds to reach full charge

var is_charging: bool = false
var charge_time: float = 0.0

func _physics_process(delta: float) -> void:
	# Always apply gravity so move_and_slide() keeps is_on_floor() reliably true
	velocity += get_gravity() * delta

	# 1. Start charging when jump is pressed on the floor
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		is_charging = true
		charge_time = 0.0
		animated_sprite.play("squish")

	# 2. Build up charge while holding the key on the floor
	if is_charging:
		if not is_on_floor():
			# Cancel charge if the player walks off a ledge while holding
			is_charging = false
			charge_time = 0.0
		elif Input.is_action_pressed("ui_accept"):
			charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		elif Input.is_action_just_released("ui_accept"):
			# 3. Release to jump with height scaled by hold duration
			var charge_ratio := clampf(charge_time / MAX_CHARGE_TIME, 0.0, 1.0)
			velocity.y = lerpf(MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY, charge_ratio)
			is_charging = false
			charge_time = 0.0
			animated_sprite.play("jump")

	# Horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Animation state machine
	if is_charging:
		if animated_sprite.animation != "squish":
			animated_sprite.play("squish")
	elif not is_on_floor():
		if animated_sprite.animation != "jump":
			animated_sprite.play("jump")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	move_and_slide()
