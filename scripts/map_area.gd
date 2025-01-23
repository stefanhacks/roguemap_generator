class_name MapArea
var width: int
var height: int
var w: get = _get_width
var h: get = _get_heigth


func _init(target_width: int, target_height: int) -> void:
	width = target_width
	height = target_height


func _get_width() -> int:
	return width


func _get_heigth() -> int:
	return height
