extends CanvasLayer

signal restart_requested
signal quit_requested

@onready var score_label: Label = %ScoreLabel

func show_game_over(score: int = 0) -> void:
	score_label.text = "Score: %d" % score
	show()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()

func _on_quit_button_pressed() -> void:
	quit_requested.emit()
