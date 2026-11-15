extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const JUMP_ACTION = "ui_accept"
const SPEED = 300.0
const MIN_JUMP_VELOCITY = -350.0
const MAX_JUMP_VELOCITY = -750.0
const MAX_CHARGE_TIME = 0.6
const DEATH_Y = 1000.0 # Adjust this to sit just below the bottom of your level

var is_charging: bool = false
var charge_time: float = 0.0
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Always apply gravity so move_and_slide() keeps is_on_floor() reliably true
	velocity += get_gravity() * delta

	# 1. Start charging when jump is pressed on the floor
	if Input.is_action_just_pressed(JUMP_ACTION) and is_on_floor():
		is_charging = true
		charge_time = 0.0
		animated_sprite.play("squish")

	# 2. Build up charge while holding the key on the floor
	if is_charging:
		if not is_on_floor():
			is_charging = false
			charge_time = 0.0
		elif Input.is_action_pressed(JUMP_ACTION):
			charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
		elif Input.is_action_just_released(JUMP_ACTION):
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

	# 3. Animation state machine
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

	# 4. Check bottom boundary death
	if global_position.y > DEATH_Y:
		die()

	# 5. Check solid obstacle collisions (StaticBody2D, TileMapLayer, etc.)
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.is_in_group("obstacles"):
			die()
			break

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	
	# Optional: If you add a "die" animation later, uncomment these 2 lines:
	# animated_sprite.play("die")
	# await animated_sprite.animation_finished
	
	get_tree().call_deferred("reload_current_scene")

# Used if your obstacles or bottom killzone are Area2D nodes
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		die()
