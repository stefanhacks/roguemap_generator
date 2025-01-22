extends Node

@export var target_room_width: int = 6
@export var target_room_height: int = 6

@onready var camera_2d: Camera2D = $Camera2D
@onready var room_generator: RoomGenerator = $RoomGenerator
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	room_generator.tile_map_layer = tile_map_layer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("generate"):
		_generate_room()
	elif event.is_action_pressed("increase_width"):
		target_room_width = target_room_width + 1
		_generate_room()
	elif event.is_action_pressed("decrease_width"):
		target_room_width = max(target_room_width - 1, 2)
		_generate_room()
	elif event.is_action_pressed("increase_height"):
		target_room_height = target_room_height + 1
		_generate_room()
	elif event.is_action_pressed("decrease_height"):
		target_room_height = max(target_room_height - 1, 2)
		_generate_room()


func _generate_room() -> void:
	tile_map_layer.clear()
	room_generator.draw_walled_room(target_room_width, target_room_height)
	camera_2d.position = Vector2i(floor(target_room_width * 16 / 2), floor((target_room_height * 16 / 2) - 4))
	room_generator.slice_corners()
