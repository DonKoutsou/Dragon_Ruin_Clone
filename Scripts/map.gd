extends Node2D

class_name Map

@export var TileM : TileMapLayer

var Visited : Array[Vector2]

static var maze : Array[Array]

static var Instance : Map

func _ready() -> void:
	Instance = self
	generate_maze()

static func CanMoveToPos(Pos : Vector3) -> bool:
	var t = maze[roundi(Pos.z)][roundi(Pos.x)]
	return t != 4 and t !=5

func generate_maze() -> void:
	var size = get_tilemap_layer_bounds()
	for y in range(size.size.y):
		var row : Array[int] = []
		
		for x in range(size.size.x):
			var cell = TileM.get_cell_source_id(Vector2i(x, y))
			# Let's say 1 = wall, 0 = open
			row.append(cell)
		maze.append(row)

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
