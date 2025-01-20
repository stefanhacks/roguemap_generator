extends Node

@onready var room_generator: RoomGenerator = $RoomGenerator
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
@onready var screen_dimensions: Vector2i = screen_size / 16
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	room_generator.tile_map_layer = tile_map_layer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate"):
		_generate_room()


func _generate_room() -> void:
	tile_map_layer.clear()
	room_generator.draw_square(Vector2i(-1, -1), screen_dimensions + Vector2i(1, 2), true)
	room_generator.draw_square(Vector2i(2, 3), Vector2i(8, 7))
	room_generator.draw_square(Vector2i(7, 9), Vector2i(12, 14))
	room_generator.draw_square(Vector2i(6, 16), Vector2i(9, 20))
	room_generator.draw_square(Vector2i(15, 8), Vector2i(20, 20))
	room_generator.draw_square(Vector2i(23, 2), Vector2i(26, 15))
