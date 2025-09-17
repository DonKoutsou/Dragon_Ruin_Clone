extends PanelContainer

class_name Minimap

@export var TileM : TileMapLayer
@export var LocationLabel : Label
@export var PlayerSprite : Sprite2D
@export var Camera : Camera2D

var InitialSize : Vector2
var MapBig : bool = false

var maze : Array[Array]

func _ready() -> void:
	InitialSize = size

func OnPositionVisited(Pos : Vector3, Direction : float) -> void:
	var pos = Vector2(roundi((Pos.x * 8) / 16), roundi((Pos.z * 8) / 16))
	var final = Vector2(pos.x * 16, pos.y * 16) + Vector2(8,8)

	Camera.position = final
	PlayerSprite.rotation = -Direction
	#var row = -16
	#for g in 3:
		#var collumn = -16
		#for z in 3:
	var mappos = TileM.local_to_map(Vector2(final.x, final.y ))
	#collumn += 16
	
	if (maze.size() - 1 < mappos.y or maze[mappos.y].size() - 1 < mappos.x):
		return
	var t = maze[mappos.y][mappos.x]
	TileM.set_cell(mappos, t, Vector2i.ZERO, Map.Instance.Testtile(mappos))
	#print("Cell {0}x {1}y set to {2}".format([mappos.y, mappos.x, t]))
			
		
		#row += 16
		#collumn = -16
		
	var p = TileM.local_to_map(Vector2(final.x, final.y))
	LocationLabel.text = "{0}\n{1}".format([AngleToDirection(Direction),p])

static func AngleToDirection(angle: float) -> String:
	var directions = ["North","Northeast", "West", "Northwest",  "South", "Southwest","East", "Southeast"]
	var index = int(fmod((angle + PI/8 + TAU), TAU) / (PI / 4)) % 8
	return directions[index]

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("Map")):
		if (MapBig):
			#set_anchors_preset(Control.PRESET_FULL_RECT)
			size = get_viewport_rect().size
			MapBig = false
			$HBoxContainer/VBoxContainer.visible = false
			Camera.zoom = Vector2(0.5,0.5)
		else:
			set_anchors_preset(Control.PRESET_TOP_LEFT)
			size = InitialSize
			MapBig = true
			$HBoxContainer/VBoxContainer.visible = true
			Camera.zoom = Vector2(1,1)
