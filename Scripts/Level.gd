extends Node3D

class_name Level

@export var MapScene : PackedScene
@export var Pl : Player
@export var Mat : ShaderMaterial
@export var WallMultimesh : MultiMeshInstance3D
@export var FloorMultiMesh : MultiMeshInstance3D

var cell_size = 2.0

var SpawnPoint : Vector3
var Meshcount : int = 0

var Maze : Array[Array]

func _ready():
	var TileMS = MapScene.instantiate() as Map
	add_child(TileMS)
	build_maze_3d(Map.maze)
	Pl.Teleport(Vector3(SpawnPoint.x, 1, SpawnPoint.z))
	TileMS.visible = false

func build_maze_3d(maze:Array[Array]):
	Maze = maze
	
	var BoxMeshes : Array[Vector3]
	var FloorMeshes : Array[Vector3]
	
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			var pos = Vector3(x * 2, 0, y * 2)
			#Floor
			if (maze[y][x] == 0):
				FloorMeshes.append(pos)
				#Ceiling
				BoxMeshes.append(pos + Vector3(0,3,0))
			#Wall
			else : if maze[y][x] == 1:
				BoxMeshes.append(pos + Vector3(0,1,0))
			#Entrance
			if (maze[y][x] == 2):
				FloorMeshes.append(pos)
				SpawnPoint = pos
				BoxMeshes.append(pos + Vector3(0,1,0))
			#Exit
			if (maze[y][x] == 3):
				FloorMeshes.append(pos)
				BoxMeshes.append(pos + Vector3(0,1,0))
	
	FloorMultiMesh.multimesh.instance_count = FloorMeshes.size()
	for g in FloorMeshes.size():
		FloorMultiMesh.multimesh.set_instance_transform(g, Transform3D(Basis(), FloorMeshes[g]))
	
	WallMultimesh.multimesh.instance_count = BoxMeshes.size()
	for g in BoxMeshes.size():
		WallMultimesh.multimesh.set_instance_transform(g, Transform3D(Basis(), BoxMeshes[g]))

#old randomised generator
func _build_maze(maze):
	var width = maze.size()
	var height = maze[0].size()
	for y in range(height):
		for x in range(width):
			var cell = maze[y][x]
			var cell_pos = Vector3(x * cell_size, 0, y * cell_size)
			
			# Make floor
			var floor = MeshInstance3D.new()
			floor.mesh = PlaneMesh.new()
			floor.position = cell_pos
			add_child(floor)
			
			# Walls
			for dir in range(4):
				if cell["walls"][dir]:
					var wall = MeshInstance3D.new()
					wall.mesh = BoxMesh.new()
					wall.scale = Vector3(cell_size, 2, 0.2)
					
					match dir:
						0: wall.position = cell_pos + Vector3(0, 1, -cell_size/2) # North
						1: wall.position = cell_pos + Vector3(cell_size/2, 1, 0)  # East
						2: wall.position = cell_pos + Vector3(0, 1, cell_size/2)  # South
						3: wall.position = cell_pos + Vector3(-cell_size/2, 1, 0) # West
						## Adjust rotation for east/west
					if dir in [1, 3]:
						wall.rotation.y = deg_to_rad(90)
					
					add_child(wall)
