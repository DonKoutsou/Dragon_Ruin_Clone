extends PanelContainer

class_name Minimap

@export var TileM : TileMapLayer
@export var LocationLabel : Label
@export var PlayerSprite : Sprite2D


static var instance : Minimap

func _ready() -> void:
	instance = self

func OnPositionVisited(Pos : Vector3, Direction : float) -> void:
	var pos = Vector2(roundi((Pos.x * 8) / 16), roundi((Pos.z * 8) / 16))
	var final = Vector2(pos.x * 16, pos.y * 16) + Vector2(8,8)
	
	
	
	var maze = Map.maze
	$HBoxContainer/SubViewportContainer/SubViewport/Camera2D.position = final
	PlayerSprite.rotation = -Direction
	var row = -16
	for g in 3:
		var collumn = -16
		for z in 3:
			var mappos = TileM.local_to_map(Vector2(final.x + row, final.y + collumn))
			var t = maze[mappos.y][mappos.x]
			TileM.set_cell(mappos, t, Vector2i.ZERO, Map.Instance.Testtile(mappos))
			print("Cell {0}x {1}y set to {2}".format([mappos.y, mappos.x, t]))
			collumn += 16
		
		row += 16
		collumn = -16
		
	var p = TileM.local_to_map(Vector2(final.x, final.y))
	LocationLabel.text = "{0}\n{1}".format([AngleToDirection(Direction),p])

static func AngleToDirection(angle: float) -> String:
	var directions = ["North","Northeast", "West", "Northwest",  "South", "Southwest","East", "Southeast"]
	var index = int(fmod((angle + PI/8 + TAU), TAU) / (PI / 4)) % 8
	return directions[index]
