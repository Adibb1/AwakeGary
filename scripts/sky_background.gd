extends Control
## Sky that fades from daylight blue to a starry night as the player climbs.

const VIEW := Vector2(1152, 648)

# [altitude, colour]
const STOPS := [
	[0.0, Color(0.30, 0.76, 1.00)],
	[1500.0, Color(0.20, 0.52, 0.95)],
	[3500.0, Color(0.55, 0.34, 0.70)],
	[5500.0, Color(0.06, 0.05, 0.18)],
	[8000.0, Color(0.01, 0.01, 0.06)],
]

var altitude := 0.0
var _stars: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = VIEW
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in 130:
		_stars.append([rng.randf() * VIEW.x, rng.randf() * VIEW.y, rng.randf_range(2.0, 4.5), rng.randf() * TAU])


func _process(_delta: float) -> void:
	queue_redraw()


func _color_at(alt: float) -> Color:
	if alt <= STOPS[0][0]:
		return STOPS[0][1]
	for i in range(1, STOPS.size()):
		if alt <= STOPS[i][0]:
			var a: float = STOPS[i - 1][0]
			var b: float = STOPS[i][0]
			return (STOPS[i - 1][1] as Color).lerp(STOPS[i][1], (alt - a) / (b - a))
	return STOPS[STOPS.size() - 1][1]


func _draw() -> void:
	var bottom := _color_at(altitude)
	var top := _color_at(altitude + 1500.0)
	draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(VIEW.x, 0), Vector2(VIEW.x, VIEW.y), Vector2(0, VIEW.y)]),
		PackedColorArray([top, top, bottom, bottom])
	)

	var star_alpha := clampf((altitude - 2800.0) / 2500.0, 0.0, 1.0)
	if star_alpha <= 0.0:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var scroll := fmod(altitude * 0.15, VIEW.y)
	for s in _stars:
		var y := fposmod(s[1] + scroll, VIEW.y)
		var twinkle := 0.65 + 0.35 * sin(t * 2.0 + s[3])
		draw_rect(Rect2(s[0], y, s[2], s[2]), Color(1, 1, 0.9, star_alpha * twinkle))
