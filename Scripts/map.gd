extends Node2D

class_name Map

@export var TileMaps : Array[TileMapLayer]
@export var Monsters : Array[Monster]

static var TileMapLayers : Array[TileMapLayer]

var maze : Array[Array]
var SpawnPoint : Vector2
var MonsterHouses : Array[MonsterHouse]

func _ready() -> void:
	TileMapLayers.clear()
	for g in TileMaps:
		TileMapLayers.append(g)
		
	generate_maze()

func GetMonsterHouseForPosition(Pos : Vector2i) -> MonsterHouse:
	var MonsterHouseOnPosition : MonsterHouse
	for g in MonsterHouses:
		if (g.Tiles.has(Pos)):
			MonsterHouseOnPosition = g
			break

	return MonsterHouseOnPosition

func generate_maze() -> void:
	var rect = TileMapLayers[0].get_used_rect()
	var size = rect.size + rect.position
	for y in range(size.y):
		var row : Array[int] = []
		
		for x in range(size.x):
			var cell = GetIndexFromAtlasCoords(TileMapLayers[0].get_cell_atlas_coords(Vector2i(x, y)))
			if (TileMapLayers[1].get_cell_source_id(Vector2i(x, y)) == 2):
				SpawnPoint = Vector2(x, y)
			row.append(cell)
			
		maze.append(row)
		
	var AllTiles = TileMapLayers[0].get_used_cells()

	var rooms = separate_into_rooms(AllTiles)
	print("Room ammount : {0}".format([rooms.size()]))
	for room in rooms:
		var Spawns = GetMonsterSpawnsOnRoom(room)
		if (Spawns.size() == 1):
			var MHouse = MonsterHouse.new()
			MHouse.Tiles = room
			for g in 2:
				var monster = Monsters.pick_random()
				MHouse.AddMonster(monster)
			MonsterHouses.append(MHouse)
		else:
			for spn in Spawns:
				var spawnarea = flood_fill_ranged(spn, room, 5, {})
				var MHouse = MonsterHouse.new()
				MHouse.Tiles = spawnarea
				for g in 2:
					var monster = Monsters.pick_random()
					MHouse.AddMonster(monster)
				MonsterHouses.append(MHouse)
				
	print("Monster Houses ammount : {0}".format([MonsterHouses.size()]))
	
func GetMonsterSpawnsOnRoom(room : Array) -> Array[Vector2i]:
	var Spawns : Array[Vector2i]
	for g : Vector2i in TileMapLayers[1].get_used_cells_by_id(0):
		if (room.has(g)):
			Spawns.append(g)
	return Spawns
	
func separate_into_rooms(tile_coords: Array) -> Array:
	var rooms := []
	var visited := {}

	for coord in tile_coords:
		if coord in visited:
			continue
		var room = flood_fill(coord, tile_coords, visited)
		rooms.append(room)

	return rooms

func SeparateIntoCorridors(tile_coords: Array) -> Array:
	var Corridors := []
	var visited := {}

	for coord in tile_coords:
		if coord in visited:
			continue
		var room = flood_fill_ranged(coord, tile_coords, 5, visited)
		Corridors.append(room)

	return Corridors

func flood_fill(start: Vector2i, tile_coords: Array, visited: Dictionary) -> Array:
	var room : Array = []
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
	
	return room

func flood_fill_ranged(start: Vector2i, tile_coords: Array, dist : float, visited: Dictionary) -> Array:
	var room : Array = []
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
			if start.distance_to(current + neighbor) < dist and current + neighbor in tile_coords and neighbor + current not in visited and !CantReach(current, neighbor) and !CantReach(current + neighbor, neighbor * -1):
				stack.push_back(neighbor + current)
	
	return room
	
func CantReach(tilecoords : Vector2, dir : Vector2) -> bool:
	var index = GetIndexFromAtlasCoords(TileMapLayers[0].get_cell_atlas_coords(tilecoords))
	var tilerotation = GetTileRotationRadians(tilecoords)
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
	else : if (index == 9):
		var rot1 = Vector2.RIGHT.rotated(tilerotation)
		resault = !dir.is_equal_approx(rot1)
	else : if (index == 10):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.DOWN.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1) or dir.is_equal_approx(rot2)
	else : if (index == 11):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.UP.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1) or dir.is_equal_approx(rot2)
	else : if (index == 12):
		var rot1 = Vector2.LEFT.rotated(tilerotation)
		var rot2 = Vector2.RIGHT.rotated(tilerotation)
		resault = dir.is_equal_approx(rot1) or dir.is_equal_approx(rot2)
	return resault
	
static func GetIndexFromAtlasCoords(Coords : Vector2) -> int:
	var Index = -1
	match(Coords):
		Vector2(0,0):
			Index = 0
		Vector2(1,0):
			Index = 1
		Vector2(2,0):
			Index = 2
		Vector2(0,1):
			Index = 3
		Vector2(1,1):
			Index = 4
		Vector2(2,1):
			Index = 5
		Vector2(0,2):
			Index = 6
		Vector2(1,2):
			Index = 7
		Vector2(2,2):
			Index = 8
		Vector2(0,3):
			Index = 9
		Vector2(1,3):
			Index = 10
		Vector2(2,3):
			Index = 11
		Vector2(0,4):
			Index = 12
	return Index

static func GetAtlasCoordsFromIndex(Index : int) -> Vector2:
	var Coords = Vector2(0,0)
	match(Index):
		0 :
			Coords =Vector2(0,0)
		1 :
			Coords = Vector2(1,0)
		2 :
			Coords = Vector2(2,0)
		3 :
			Coords = Vector2(0,1)
		4 :
			Coords = Vector2(1,1)
		5 :
			Coords = Vector2(2,1)
		6 :
			Coords = Vector2(0,2)
		7 :
			Coords = Vector2(1,2)
		8 :
			Coords =Vector2(2,2)
		9 :
			Coords =Vector2(0,3)
		10 :
			Coords =Vector2(1,3)
		11 :
			Coords =Vector2(2,3)
		12 :
			Coords =Vector2(0,4)
	return Coords

static func Testtile(pos : Vector2i) -> int:
	var tile_alternate : int = 0
	var rot = GetTileRotationDegrees(pos)
	match rot:
		-90.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
		180.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
		90.0:
			tile_alternate = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
	return tile_alternate

static func GetTileRotationDegrees(pos : Vector2i) -> float:
	var rot : float = 0
	if TileMapLayers[0].is_cell_flipped_h(pos) == false and TileMapLayers[0].is_cell_flipped_v(pos) == false:
		rot = 0
	elif TileMapLayers[0].is_cell_flipped_h(pos) == true and TileMapLayers[0].is_cell_flipped_v(pos) == false:
		rot = -90
	elif TileMapLayers[0].is_cell_flipped_h(pos) == false and TileMapLayers[0].is_cell_flipped_v(pos) == true:
		rot = 90
	elif TileMapLayers[0].is_cell_flipped_h(pos) == true and TileMapLayers[0].is_cell_flipped_v(pos) == true:
		rot = 180
	return rot

static func GetTileRotationRadians(pos : Vector2i) -> float:
	var rot : float = 0
	if TileMapLayers[0].is_cell_flipped_h(pos) == false and TileMapLayers[0].is_cell_flipped_v(pos) == false:
		rot = 0
	elif TileMapLayers[0].is_cell_flipped_h(pos) == true and TileMapLayers[0].is_cell_flipped_v(pos) == false:
		rot = PI/2
	elif TileMapLayers[0].is_cell_flipped_h(pos) == false and TileMapLayers[0].is_cell_flipped_v(pos) == true:
		rot = -PI/2
	elif TileMapLayers[0].is_cell_flipped_h(pos) == true and TileMapLayers[0].is_cell_flipped_v(pos) == true:
		rot = PI
	return rot
