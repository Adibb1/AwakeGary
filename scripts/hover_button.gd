extends Button

@export var hover_scale: Vector2 = Vector2(1.08, 1.08)
@export var press_scale: Vector2 = Vector2(0.95, 0.95)

var _tween: Tween


func _ready() -> void:
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)
	mouse_entered.connect(func(): _go(hover_scale, 0.15))
	mouse_exited.connect(func(): _go(Vector2.ONE, 0.15))
	button_down.connect(func(): _go(press_scale, 0.08))
	button_up.connect(func(): _go(hover_scale if is_hovered() else Vector2.ONE, 0.1))


func _go(target: Vector2, duration: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "scale", target, duration)
