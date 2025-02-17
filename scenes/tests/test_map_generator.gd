extends Node

const DOUBLE_TAP_DELAY = 0.25
enum TapStage { GENERATE, ADD, MAKE }

@onready var map_generator: MapGenerator = $MapGenerator
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
@onready var screen_dimensions: Vector2i = screen_size / 16
@onready var ui: CanvasLayer = $UI

var tile_map_layer: TileMapLayer
var double_tap_span = DOUBLE_TAP_DELAY
var current_stage = TapStage.GENERATE


func _ready() -> void:
	tile_map_layer = map_generator.make_tile_map_layer()


func _physics_process(delta: float) -> void:
	double_tap_span = max(0, double_tap_span - delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate") or _is_double_tap_stage(event, TapStage.GENERATE):
		_generate_room()
	elif event.is_action_pressed("add") or _is_double_tap_stage(event, TapStage.ADD):
		_add_random_road()
	elif event.is_action_pressed("make_road") or _is_double_tap_stage(event, TapStage.MAKE):
		_make_roads()


func _is_double_tap(event: InputEvent) -> bool:
	if event.is_action_released("click"):
		if double_tap_span > 0:
			double_tap_span = 0
			return true
		else:
			double_tap_span = DOUBLE_TAP_DELAY
	
	return false


func _is_double_tap_stage(event: InputEvent, stage: TapStage) -> bool:
	return current_stage == stage and _is_double_tap(event)
	

func _generate_room() -> void:
	ui.fade_ui()
	tile_map_layer.clear()
	map_generator.make_map(Vector2i(-1, -1), screen_dimensions + Vector2i(1, 2))
	current_stage = TapStage.ADD


func _add_random_road() -> void:
	if tile_map_layer != null:
		map_generator.add_random_road()
		current_stage = TapStage.MAKE


func _make_roads() -> void:
	if tile_map_layer != null:
		map_generator.make_roads()
		current_stage = TapStage.GENERATE
