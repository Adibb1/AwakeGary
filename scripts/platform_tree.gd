extends StaticBody2D
## Tree platform: a solid, permanent platform. Land on the leaves from above.


func _ready() -> void:
	add_to_group("platforms")
	$Sprite2D.flip_h = randf() < 0.5
