class_name MapGenerator
extends Node

@export var proportions: Array[float] = [0.9, 1.0, 1.1]
@export var merge_chances: Array[float] = [1.0, 0.8, 0.4]

@onready var room_nodes: Node = $Rooms
@onready var background_generator: RoomGenerator = $BackgroundGenerator
@onready var path_generator: PathGenerator = $PathGenerator

var tile_map_layer: TileMapLayer
var next_gen_id = 0
var slices_through_x: Array[int]
var slices_through_y: Array[int]

const ROOM_GENERATOR = preload("res://scenes/components/room_generator.tscn")
const tile_set: TileSet = preload("res://tilesets/dungeon_tile_set.tres")
enum {MERGED_EAST, MERGED_SOUTH}


func make_tile_map_layer() -> TileMapLayer:
	var new_tile_map_layer = TileMapLayer.new()
	new_tile_map_layer.name = "TileMapLayer"
	new_tile_map_layer.tile_set = tile_set
	
	tile_map_layer = new_tile_map_layer
	background_generator.tile_map_layer = tile_map_layer
	path_generator.tile_map_layer = tile_map_layer
	
	add_child(tile_map_layer)
	return new_tile_map_layer


func make_map(origin: Vector2i, end: Vector2i) -> void:
	var dimensions = end - origin
	_make_background(dimensions)
	
	# map_areas cells are null'd after being merged function
	var map_areas: Array[Array] = _make_slices(dimensions)
	var merged_map_areas: Array[Array] = _merge_areas(map_areas)
	
	# Room counting
	var room_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8]
	room_numbers.shuffle()
	var skips = randi_range(1, 3)
	var rooms_to_skip = room_numbers.slice(0, skips + 1)
	
	# Shuffles non merged map_area lines to create more diversity
	var map: Array[Array] = _distribute_areas(map_areas, merged_map_areas)
	var offset: Vector2i = Vector2i.ZERO
	var current_room = 0
	
	for row in map.size():
		for column in map[row].size():
			var area = map[row][column]
			if typeof(area) != TYPE_INT:
				if(!current_room in rooms_to_skip):
					_make_room(area, offset)
				current_room += 1
				offset = offset + Vector2i(area.w, 0)
			elif area == MERGED_SOUTH:
				offset = offset + Vector2i(map[row - 1][column].w, 0)
		
		offset = Vector2i(0, offset.y + slices_through_y[row])


func make_roads() -> void:
	var rooms = room_nodes.get_children()
	rooms.shuffle()
	for i in range(1, rooms.size()):
		path_generator.make_path(rooms[i - 1].room, rooms[i].room)


func add_random_road() -> void:
	var rooms = room_nodes.get_children()
	if rooms.size() > 0:
		rooms.shuffle()
		path_generator.make_path(rooms[0].room, rooms[1].room)


func _make_background(dimensions: Vector2i) -> void:
	background_generator.draw_square(Vector2i(-1, -1), dimensions + Vector2i(1, 2), true)
	for child in room_nodes.get_children(): child.queue_free()


func _make_slices(dimensions: Vector2i) -> Array[Array]:
	slices_through_x = _slice_through(dimensions.x, 3)
	slices_through_y = _slice_through(dimensions.y, 3)
	
	# Shuffle
	slices_through_x.shuffle()
	slices_through_y.shuffle()
	
	var map: Array[Array] = [
		[MapArea.new(slices_through_x[0], slices_through_y[0]), MapArea.new(slices_through_x[1], slices_through_y[0]), MapArea.new(slices_through_x[2], slices_through_y[0])],
		[MapArea.new(slices_through_x[0], slices_through_y[1]), MapArea.new(slices_through_x[1], slices_through_y[1]), MapArea.new(slices_through_x[2], slices_through_y[1])],
		[MapArea.new(slices_through_x[0], slices_through_y[2]), MapArea.new(slices_through_x[1], slices_through_y[2]), MapArea.new(slices_through_x[2], slices_through_y[2])],
	]
	
	return map


func _slice_through(length: int, size: int) -> Array[int]:
	return [
		length / size * proportions[0],
		length / size * proportions[1], 
		length / size * proportions[2],
	]


func _merge_areas(map_areas: Array[Array]) -> Array[Array]:
	var map_with_merged_cells: Array[Array] = [
		[null, null, null],
		[null, null, null],
		[null, null, null],
	]
	
	# Define which cells merge east or south
	var chances_to_merge = merge_chances.duplicate()
	while chances_to_merge.size() > 0:
		var next_chance = chances_to_merge.pop_front()
		if next_chance < randf():
			continue
		
		# Rands for east or south expansion
		# if expanding east, last column cannot be selected
		# if expanding south, bottom row cannot be selected
		var merge_east = true if randi_range(0, 1) % 2 == 0 else false
		var x_mod = 1 if merge_east else 0
		var y_mod = 0 if merge_east else 1
		
		# x_mod and y_mod change how access works based on expansion
		# rands are capped based on wether they can use the last index or not
		var x_to_merge = randi_range(0, 1 + y_mod)
		var y_to_merge = randi_range(0, 1 + x_mod)
		
		# neighbor is selected based on expansion as well
		var cell = map_areas[y_to_merge][x_to_merge]
		var neighbor = map_areas[y_to_merge + y_mod][x_to_merge + x_mod]
		
		# if a merged cell is selected, give it another chance
		if cell == null or neighbor == null:
			chances_to_merge.push_front(next_chance)
			continue
		
		# end result is a new area with the sum of the expanded axis
		# however, it also keeps the unexpanded axis utilizing the logic above
		var result = MapArea.new(cell.w + (neighbor.w * x_mod), cell.h + (neighbor.h * y_mod))
		map_with_merged_cells[y_to_merge + y_mod][x_to_merge + x_mod] = MERGED_EAST if merge_east else MERGED_SOUTH
		map_with_merged_cells[y_to_merge][x_to_merge] = result
		
		# Clear map_areas and neighbor ref
		map_areas[y_to_merge][x_to_merge] = null
		map_areas[y_to_merge + y_mod][x_to_merge + x_mod] = null
	
	return map_with_merged_cells


func _distribute_areas(map_areas: Array[Array], merged_map_areas: Array[Array]) -> Array[Array]:
	# map_areas has "null" in spots where cells were merged
	for row in map_areas.size():
		var have_merged = map_areas[row].has(null)
		if !have_merged:
			map_areas[row].shuffle()
	
	for row in merged_map_areas.size():
		for column in merged_map_areas[row].size():
			if merged_map_areas[row][column] == null:
				merged_map_areas[row][column] = map_areas[row][column]
	
	return merged_map_areas


func _make_room(area: MapArea, offset: Vector2i) -> void:
	var room: RoomGenerator = ROOM_GENERATOR.instantiate()
	room.tile_map_layer = tile_map_layer
	room.name = "RoomGenerator%s" % next_gen_id
	next_gen_id += 1
	room_nodes.add_child(room)
	
	var origin: Vector2i = Vector2i(2, 2)
	var rng = Vector2i(randi_range(0, 3), randi_range(0, 2))
	var end: Vector2i = Vector2i(
		(area.w - 4) * sqrt(1 - pow(randf_range(0.3, 0.8) - 1, 2)),
		(area.h - 2) * sqrt(1 - pow(randf_range(0.4, 0.8) - 1, 2)),
	)
	
	room.draw_square(offset + origin + rng, offset + end + origin - rng / 2)
	room.slice_corners()
