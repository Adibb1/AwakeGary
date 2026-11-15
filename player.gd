extends CharacterBody2D


const SPEED = 300.0
# Strong enough to reach the clouds (apex is ~290 px with default gravity).
const JUMP_VELOCITY = -750.0
var _dead := false


func _physics_process(delta: float) -> void:
	# Gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Jump with Space.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Move with A (Left) and D (Right).
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func die()-> void:
	if _dead:
		return
	_dead = true
	get_tree().call_deferred("reload_current_scene")
