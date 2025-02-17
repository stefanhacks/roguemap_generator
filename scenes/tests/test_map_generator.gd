extends Node

const DOUBLE_TAP_DELAY = 0.25

@onready var map_generator: MapGenerator = $MapGenerator
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
@onready var screen_dimensions: Vector2i = screen_size / 16
@onready var ui: CanvasLayer = $UI

var tile_map_layer: TileMapLayer
var double_tap_span = DOUBLE_TAP_DELAY


func _ready() -> void:
	tile_map_layer = map_generator.make_tile_map_layer()


func _physics_process(delta: float) -> void:
	double_tap_span = max(0, double_tap_span - delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate") or _is_double_tap(event):
		ui.fade_ui()
		_generate_room()
	elif event.is_action_pressed("make_road"):
		if tile_map_layer != null:
			_make_roads()
	elif event.is_action_pressed("add"):
		if tile_map_layer != null:
			_add_random_road()


func _is_double_tap(event: InputEvent) -> bool:
	if event.is_action_released("click"):
		if double_tap_span > 0:
			double_tap_span = 0
			return true
		else:
			double_tap_span = DOUBLE_TAP_DELAY
	
	return false


func _generate_room() -> void:
	tile_map_layer.clear()
	map_generator.make_map(Vector2i(-1, -1), screen_dimensions + Vector2i(1, 2))


func _make_roads() -> void:
	map_generator.make_roads()


func _add_random_road() -> void:
	map_generator.add_random_road()
