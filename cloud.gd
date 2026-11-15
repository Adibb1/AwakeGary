extends StaticBody2D

##range coordinate
@export var min_y := 200.0
@export var max_y := 520.0
@export var min_x := 100.0
@export var max_x := 440.0

@export var _black_cloud := true

@export var respawn := true
@export var respawn_delay := 1.5

##connection
@onready var shape : CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $DisappearHitbox

var _touched := false


func _ready() -> void:
	add_to_group("clouds")
	sprite.sprite_frames.set_animation_loop("disappear",false)
	sprite.play("default")
	sprite.frame = randi_range(0,5)
	
	if _black_cloud:
		sprite.play("blackcloud")
		area.body_entered.connect(on_area_body_entered)
	else:
		area.monitoring=false
			
func _on_landed() -> void:
	if _touched or _black_cloud:
		return
	_touched = true
	sprite.play("disappear")
	
func _on_animation_finished() -> void:
	if sprite.animation == &"disappear":
		queue_free()
	
func on_area_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")
		
func random_position() -> Vector2:
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
