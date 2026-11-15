extends Node2D

const CLOUD_SCENE := preload("res://cloud.tscn")

@export var spawn_interval := 1.5          
@export var max_clouds := 4               
@export var black_cloud_chance := 0.25  
@export var min_cloud_gap := Vector2(200, 100) 
@export var spawn_attempts := 10          

var _timer: Timer

@onready var player: CharacterBody2D = $Player
@onready var player_shape : CollisionShape2D = $Player/CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var _start_spawn_y := camera.position.y




func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_spawn_cloud)
	add_child(_timer)
	_timer.start()
	_spawn_cloud() # first cloud right away


func _spawn_cloud() -> void:
	if get_tree().get_nodes_in_group("clouds").size() >= max_clouds:
		return

	var cloud := CLOUD_SCENE.instantiate()
	# Must be set BEFORE add_child, because cloud.gd reads it in _ready().
	cloud.set("_black_cloud", randf() < black_cloud_chance)

	var found := false
	var pos := Vector2.ZERO
	for i in spawn_attempts:
		pos = cloud.call("random_position")
		pos.y += camera.position.y - _start_spawn_y
		if _is_spot_free(pos):
			found = true
			break

	if not found:
		cloud.free()
		return

	cloud.position = pos
	add_child(cloud)

func _process(delta: float)->void:
	var py := player_shape.global_position.y
	
	if py < camera.position.y:
		camera.position.y = lerpf(camera.position.y, py, 10.0 * delta)
	
	var bottom:= camera.position.y + get_viewport_rect().size.y / 2.0
	
	for c in get_tree().get_nodes_in_group("clouds"):
		if c.position.y > bottom + 100.0:
			c.queue_free()
			
	if py>bottom + 100.0:
		player.die()
		

func _is_spot_free(pos: Vector2) -> bool:
	for c in get_tree().get_nodes_in_group("clouds"):
		var d: Vector2 = (c.position - pos).abs()
		if d.x < min_cloud_gap.x and d.y < min_cloud_gap.y:
			return false
	return true
