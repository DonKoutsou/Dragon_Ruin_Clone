extends Node2D

class_name Map

@export var TileM : TileMapLayer
@export var TileM2 : TileMapLayer

var Visited : Array[Vector2]

var maze : Array[Array]
var SpawnPoint : Vector2
var MonsterHouses : Array[Array]

static var Instance : Map

func _ready() -> void:
	Instance = self
	generate_maze()

func generate_maze() -> void:
	var rect = TileM.get_used_rect()
	var size = rect.size + rect.position
	for y in range(size.y):
		var row : Array[int] = []
		
		for x in range(size.x):
			var cell = TileM.get_cell_source_id(Vector2i(x, y))
			# Let's say 1 = wall, 0 = open
			if (TileM2.get_cell_source_id(Vector2i(x, y)) == 2):
				SpawnPoint = Vector2(x, y)
			row.append(cell)
			
		maze.append(row)
		
	var AllTiles = TileM.get_used_cells()
	#var Doors = TileM.get_used_cells_by_id(6)
	#for g in Doors:
		#AllTiles.erase(g)
	var rooms = separate_into_rooms(AllTiles)
	print("Room ammount : {0}".format([rooms.size()]))
	
func separate_into_rooms(tile_coords: Array) -> Array:
	var rooms := []
	var visited := {}

	for coord in tile_coords:
		if coord in visited:
			continue
		var room := []
		flood_fill(coord, tile_coords, visited, room)
		rooms.append(room)

	return rooms

func flood_fill(start: Vector2i, tile_coords: Array, visited: Dictionary, room: Array):
	var stack := [start]

	while stack.size() > 0:
		var current = stack.pop_back()

		if current in visited:
			continue

		visited[current] = true
		room.append(current)

		# Get neighboring tiles (4-directional)
		var neighbors : Array[Vector2i] = [
			Vector2i.LEFT,
			Vector2i.RIGHT,
			Vector2i.UP,
			Vector2i.DOWN
		]

		for neighbor in neighbors:
			if current + neighbor in tile_coords and neighbor + current not in visited and !CantReach(current, neighbor) and !CantReach(current + neighbor, neighbor * -1):
				stack.push_back(neighbor + current)
			else:
				var f

func CantReach(tilecoords : Vector2, dir : Vector2) -> bool:
	var index = TileM.get_cell_source_id(tilecoords)
	var tilerotation = testrad(tilecoords)
	var resault : bool
	if (index == 0):
		resault = false
	else : if (index == 1):
		var rotatedv = Vector2.LEFT.rotated(tilerotation)
		resault = dir.is_equal_approx(rotatedv)
	else : if (index == 2):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.DOWN.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1) or dir.is_equal_approx(rot2)
	else : if (index == 3):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1)
	else : if (index == 4):
		var rot1 = Vector2.DOWN.rotated(tilerotation)
		resault = !dir.is_equal_approx(rot1)
	else : if (index == 5):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.RIGHT.rotated(tilerotation)
		resault = dir.is_equal_approx(rot2) or dir.is_equal_approx(rot1)
	else : if (index == 6):
		resault = false
	else : if (index == 7):
		var rot1 = Vector2.UP.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1)
	else : if (index == 8):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.UP.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1) or dir.is_equal_approx(rot2)
	return resault
	
func Testtile(pos : Vector2i) -> int:
	var tile_alternate : int = 0
	var rot = test(pos)
	match rot:
		-90.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
		180.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
		90.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
	return tile_alternate

func test(pos : Vector2i) -> float:
	var rot : float = 0
	if TileM.is_cell_flipped_h(pos) == false and TileM.is_cell_flipped_v(pos) == false:
		rot = 0
	elif TileM.is_cell_flipped_h(pos) == true and TileM.is_cell_flipped_v(pos) == false:
		rot = -90
	elif TileM.is_cell_flipped_h(pos) == false and TileM.is_cell_flipped_v(pos) == true:
		rot = 90
	elif TileM.is_cell_flipped_h(pos) == true and TileM.is_cell_flipped_v(pos) == true:
		rot = 180
	return rot

func testrad(pos : Vector2i) -> float:
	var rot : float = 0
	if TileM.is_cell_flipped_h(pos) == false and TileM.is_cell_flipped_v(pos) == false:
		rot = 0
	elif TileM.is_cell_flipped_h(pos) == true and TileM.is_cell_flipped_v(pos) == false:
		rot = PI/2
	elif TileM.is_cell_flipped_h(pos) == false and TileM.is_cell_flipped_v(pos) == true:
		rot = -PI/2
	elif TileM.is_cell_flipped_h(pos) == true and TileM.is_cell_flipped_v(pos) == true:
		rot = PI
	return rot
	
# Returns the rectangle (Rect2i) bounding all tiles on the given layer
func get_tilemap_layer_bounds() -> Rect2i:
	var cells := TileM.get_used_cells()
	if cells.is_empty():
		return Rect2i() # Or handle empty case specially
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	for cell in cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	var size_x = max_x - min_x + 1
	var size_y = max_y - min_y + 1
	return Rect2i(Vector2i(min_x, min_y), Vector2i(size_x, size_y))
