class_name PathGenerator
extends Node

@export var terrain_set_id: int = 0
@export var ground_terrain_id: int = 1
@export var tile_map_layer: TileMapLayer

const VERTICAL_DOOR = preload("res://tilesets/vertical_door.tscn")
const HORIZONTAL_DOOR = preload("res://tilesets/horizontal_door.tscn")

func make_path(room_a: Array[Vector2i], room_b: Array[Vector2i]) -> void:
	var parsed_a = room_a if room_a[0].x < room_b[0].x else room_b
	var parsed_b = room_b if room_b[0].x > room_a[0].x else room_a
	
	var start_point: Vector2i
	var end_point: Vector2i
	var horizontal_first = randi_range(0, 1) == 0
	
	if (horizontal_first):
		start_point = Vector2i(_get_mid_point(parsed_a).x, _get_random_point(parsed_a).y)
		end_point = Vector2i(_get_mid_point(parsed_b).x, _get_random_point(parsed_b).y)
	else:
		start_point = Vector2i(_get_random_point(parsed_a).x, _get_mid_point(parsed_a).y)
		end_point = Vector2i(_get_random_point(parsed_b).x, _get_mid_point(parsed_b).y)
		
	_draw_s_line(start_point, end_point, horizontal_first)


func _get_mid_point(room: Array[Vector2i]) -> Vector2i:
	var first = room[0]
	var last = room[room.size() - 1]
	var x = floor((last.x - first.x) / 2) + first.x
	var y = floor((last.y - first.y) / 2) + first.y
	var mid_point = Vector2i(x, y)
	return mid_point


func _get_random_point(room: Array[Vector2i]) -> Vector2i:
	var first = room[0]
	var last = room[room.size() - 1]
	var x = randi_range(first.x, last.x)
	var y = randi_range(first.y, last.y)
	var random_point = Vector2i(x, y)
	return random_point


func _draw_s_line(from: Vector2i, to: Vector2i, is_horizontal: bool) -> void:
	var distance = abs(to.x - from.x) if is_horizontal else abs(to.y - from.y)
	var curve_at = randi_range(distance / 3, distance * 2 / 3)
	var curve_length = abs(to.y - from.y) if is_horizontal else abs(to.x - from.x)
	var last_step = from
	
	last_step = _draw_segment(last_step, to, is_horizontal, curve_at)
	last_step = _draw_corner(last_step, to, curve_length, !is_horizontal)
	_draw_segment(last_step, to, is_horizontal, 0)


func _draw_s(from: Vector2i, to: Vector2i, is_horizontal: bool) -> Vector2i:
	var entrance_door = false
	var horizontal_distance = abs(to.x - from.x)
	var vertical_distance = abs(to.y - from.y)
	var distance
	var curve_length
	
	distance = horizontal_distance if is_horizontal else vertical_distance
	curve_length = vertical_distance if is_horizontal else horizontal_distance
		
	var curve_at = randi_range(distance / 3, distance * 2 / 3)
	for i in range(distance + curve_length):
		if i == curve_at or i == curve_at + curve_length:
			is_horizontal = !is_horizontal
		if is_horizontal:
			from.x += 1 if to.x > from.x else -1
		else:
			from.y += 1 if to.y > from.y else -1

		var current_cell = tile_map_layer.get_cell_tile_data(from)
		if current_cell == null or current_cell.terrain != ground_terrain_id:
			tile_map_layer.set_cells_terrain_connect([from], terrain_set_id, ground_terrain_id)
			if !entrance_door:
				var local_position = tile_map_layer.map_to_local(from)
				_add_door(local_position, !is_horizontal)
				entrance_door = true
	
	return from
	
	
func _draw_segment(from: Vector2i, to: Vector2i, is_horizontal: bool, offset = 0) -> Vector2i:
	var span = abs(to.x - from.x if is_horizontal else to.y - from.y)
	var path = []
	for i in range(span - offset):
		if is_horizontal:
			from.x += 1 if to.x > from.x else -1
		else:
			from.y += 1 if to.y > from.y else -1
			
		var current_cell = tile_map_layer.get_cell_tile_data(from)
		if current_cell == null or current_cell.terrain != ground_terrain_id:
			path.append(from)
	
	tile_map_layer.set_cells_terrain_connect(path, terrain_set_id, ground_terrain_id)
	return from


func _draw_corner(from: Vector2i, to: Vector2i, length: int, is_horizontal: bool) -> Vector2i:
	var path = []
	for l in range(length):
		if is_horizontal:
			from.x += 1 if to.x > from.x else -1
		else:
			from.y += 1 if to.y > from.y else -1
			
		var current_cell = tile_map_layer.get_cell_tile_data(from)
		if current_cell == null or current_cell.terrain != ground_terrain_id:
			path.append(from)
	
	tile_map_layer.set_cells_terrain_connect(path, terrain_set_id, ground_terrain_id)
	return from


func _add_door(at: Vector2i, is_horizontal: bool) -> void:
	var new_door: Node = HORIZONTAL_DOOR.instantiate() if is_horizontal else VERTICAL_DOOR.instantiate()
	tile_map_layer.add_child(new_door)
	new_door.position = at


# add door if
