extends Node2D

@onready var path_generator: PathGenerator = $PathGenerator
@onready var room_a: RoomGenerator = $RoomA
@onready var room_b: RoomGenerator = $RoomB
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
@onready var screen_dimensions: Vector2i = screen_size / 16


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate"):
		_generate()
	elif event.is_action_pressed("make_road"):
		if room_a.room.size() != 0 and room_b.room.size() != 0:
			_path()


func _generate() -> void:
	var room_a_height = randi_range(1, 23)
	var room_b_height = randi_range(1, 23)
	tile_map_layer.clear()
	room_a.draw_square(Vector2i(8, room_a_height), Vector2i(16, room_a_height + 8))
	room_b.draw_square(Vector2i(screen_dimensions.x - 16, room_b_height), Vector2i(screen_dimensions.x - 8, room_b_height + 8))


func _path() -> void:
	path_generator.make_path(room_a.room, room_b.room)
