extends SubViewportContainer

class_name Minimap

@export var TileM : TileMapLayer

static var instance : Minimap

func _ready() -> void:
	instance = self

func OnPositionVisited(Pos : Vector3) -> void:
	var pos = Vector2(roundi((Pos.x * 8) / 16), roundi((Pos.z * 8) / 16))
	var final = Vector2(pos.x * 16, pos.y * 16) + Vector2(8,8)
	
	var maze = Map.maze
	$SubViewport/Camera2D.position = final
	var row = -16
	for g in 3:
		var collumn = -16
		for z in 3:
			var mappos = TileM.local_to_map(Vector2(final.x + row, final.y + collumn))
			var t = maze[mappos.y][mappos.x]
			TileM.set_cell(mappos, t, Vector2i.ZERO, 0)
			print("Cell {0}x {1}y set to {2}".format([mappos.y, mappos.x, t]))
			collumn += 16
		
		row += 16
		collumn = -16
