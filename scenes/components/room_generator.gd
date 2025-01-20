class_name RoomGenerator
extends Node

@export var terrain_set_id: int = 0
@export var wall_terrain_id: int = 0
@export var ground_terrain_id: int = 1
@export var tile_map_layer: TileMapLayer

var first_cell: Vector2i
var last_cell: Vector2i
var width: int
var height: int
var room: Array[Vector2i]:
	set(new_room):
		room = new_room
		if room.size() > 0:
			room.sort()
			first_cell = room[0]
			last_cell = room[room.size() - 1]
			width = last_cell[0] - first_cell[0]
			height = last_cell[1] - first_cell[1]


func draw_walled_room(new_width: int, new_height: int, save_as_room = true) -> void:
	# Room requires 2 additional walls on each of the sides so the wrapping look nice
	var columns: int = new_width + 4
	var rows: int = new_height + 4
	
	var is_frame_horizontal: bool = false
	var is_frame_vertical: bool = false
	
	var ground: Array[Vector2i] = []
	var walls: Array[Vector2i] = []
	
	for i in range(rows):
		is_frame_horizontal = (i <= 1) or (i >= rows - 2)
		for j in range(columns):
			is_frame_vertical = (j <= 1) or (j >= columns - 2)
			var cell_coord = Vector2i(j - 2, i - 2)
			
			if is_frame_horizontal or is_frame_vertical:
				walls.push_front(cell_coord)
			else:
				ground.push_front(cell_coord)
	
	if save_as_room:
		room = ground + walls
	tile_map_layer.set_cells_terrain_connect(ground, terrain_set_id, ground_terrain_id)
	tile_map_layer.set_cells_terrain_connect(walls, terrain_set_id, wall_terrain_id)


func draw_square(origin: Vector2i, end: Vector2i, is_wall = false, save_as_room = true) -> void:
	var parsed_origin = Vector2i(mini(origin.x, end.x), mini(origin.y, end.y))
	var parsed_end = Vector2i(maxi(origin.x, end.x), maxi(origin.y, end.y))
	
	var columns: int = parsed_end.x - parsed_origin.x
	var rows: int = parsed_end.y - parsed_origin.y
		
	var new_room: Array[Vector2i] = []
	
	for i in range(columns):
		for j in range(rows):
			var cell_coord = Vector2i(i + parsed_origin.x, j + parsed_origin.y)
			new_room.push_front(cell_coord)
	
	if save_as_room:
		room = new_room
	var terrain_id = wall_terrain_id if is_wall else ground_terrain_id
	tile_map_layer.set_cells_terrain_connect(new_room, terrain_set_id, terrain_id)


func slice_corners() -> void:
	slice_top_left()
	slice_top_right()
	slice_bottom_left()
	slice_bottom_right()


func slice_top_left() -> void:
	var slice_width = floor(randf_range(0.2, 1) * width / 2)
	var slice_height = floor(randf_range(0.2, 1) * height / 2)
	draw_square(first_cell, first_cell + Vector2i(slice_width, slice_height), true, false)
	
	
func slice_top_right() -> void:
	var slice_width = floor(randf_range(0.2, 1) * width / 2)
	var slice_height = floor(randf_range(0.2, 1) * height / 2)
	
	var top_right = Vector2i(last_cell[0] + 1, first_cell[1])
	draw_square(top_right + Vector2i(-slice_width, slice_height), top_right,  true, false)
	
	
func slice_bottom_left() -> void:
	var slice_width = floor(randf_range(0.2, 1) * width / 2)
	var slice_height = floor(randf_range(0.2, 1) * height / 2)
	
	var bottom_left = Vector2i(first_cell[0], last_cell[1] + 1)
	draw_square(bottom_left, bottom_left + Vector2i(slice_width, -slice_height),  true, false)
	
	
func slice_bottom_right() -> void:
	var slice_width = floor(randf_range(0.2, 1) * width / 2)
	var slice_height = floor(randf_range(0.2, 1) * height / 2)
	draw_square(last_cell - Vector2i(slice_width, slice_height), last_cell + Vector2i.ONE,  true, false)
	
