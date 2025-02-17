extends CanvasLayer

@onready var margin_container: MarginContainer = $MarginContainer

var fading = false

func fade_ui() -> void:
	if fading: return
	fading = true
	
	await get_tree().create_timer(3).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(margin_container, "modulate:a", 0, 1)
