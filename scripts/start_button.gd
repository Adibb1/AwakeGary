extends Button

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var press_scale: Vector2 = Vector2(0.95, 0.95)
var default_scale: Vector2

func _ready() -> void:
	default_scale = scale
	pivot_offset = size / 2.0
	pressed.connect(_on_pressed)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", hover_scale, 0.15)

func _on_mouse_exited() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", default_scale, 0.15)

func _on_pressed() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", press_scale, 0.08)
	get_tree().quit()

func _on_button_up() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", hover_scale if get_rect().has_point(get_local_mouse_position()) else default_scale, 0.1)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
