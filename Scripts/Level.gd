extends Node3D

class_name Level

@export var MapScene : PackedScene
@export var Mat : ShaderMaterial
@export var WallMultimesh : MultiMeshInstance3D
@export var FloorMultiMesh : MultiMeshInstance3D
@export var FlatWallMultimesh : MultiMeshInstance3D
@export var WallCollission : StaticBody3D
@export var CornerWallMultimesh : MultiMeshInstance3D
@export var DoorWallMultimesh : MultiMeshInstance3D

var cell_size = 2.0

var SpawnPoint : Vector3
var Meshcount : int = 0

var Maze : Array[Array]

func SpawnPlayer(Pl : Player) -> void:
	add_child(Pl)
	Pl.call_deferred("Teleport", SpawnPoint)

func BuildMaze(maze : Array[Array], SpawnP : Vector2):
	Maze = maze
	#Multiply by to to convert to 3D coordinates
	SpawnPoint = Vector3(SpawnP.x * 2, 1, SpawnP.y * 2)

	var FloorMeshes : Array[Transform3D]
	var WallMeshes : Array[Transform3D]
	var CornerWallMeshes : Array[Transform3D]
	var DoorWallMeshes : Array[Transform3D]
	
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			var pos = Vector3(x * 2, 0, y * 2)
			var rot = Map.GetTileRotationDegrees(Vector2i(pos.x, pos.z) / 2)
			#Floor
			FloorMeshes.append(Transform3D(Basis(), pos))
			#Ceiling
			FloorMeshes.append(Transform3D(Basis(), pos + Vector3(0,2,0)))

			#Wall
			if (maze[y][x] == 1):
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot)), pos + Vector3(0,1,0)))
			#Corner
			else : if (maze[y][x] == 2):
				CornerWallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot)), pos + Vector3(0,1,0)))
			#Door
			else : if (maze[y][x] == 3):
				DoorWallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(Map.GetTileRotationDegrees(Vector2i(pos.x, pos.z) / 2))), pos + Vector3(0,1,0)))
			#Cap
			else : if (maze[y][x] == 4):
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot)), pos + Vector3(0,1,0)))
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot + 180)), pos + Vector3(0,1,0)))
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot - 90)), pos + Vector3(0,1,0)))
			#Corridor
			else : if (maze[y][x] == 5):
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot)), pos + Vector3(0,1,0)))
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot + 180)), pos + Vector3(0,1,0)))
			#T section
			else : if (maze[y][x] == 7):
				WallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot - 90)), pos + Vector3(0,1,0)))
			#Corner
			else : if (maze[y][x] == 8):
				CornerWallMeshes.append(Transform3D(Basis().rotated(Vector3(0,1,0), deg_to_rad(rot - 90)), pos + Vector3(0,1,0)))
				
	#Floors
	FloorMultiMesh.multimesh.instance_count = FloorMeshes.size()
	for g in FloorMeshes.size():
		FloorMultiMesh.multimesh.set_instance_transform(g, FloorMeshes[g])
	
	#Walls
	FlatWallMultimesh.multimesh.instance_count = WallMeshes.size()
	var WallShape = FlatWallMultimesh.multimesh.mesh.create_trimesh_shape()
	WallShape.backface_collision = true
	for g in WallMeshes.size():
		var pos = WallMeshes[g]
		
		var collision = CollisionShape3D.new()
		collision.shape = WallShape
		WallCollission.add_child(collision)
		collision.transform = pos
		
		FlatWallMultimesh.multimesh.set_instance_transform(g, pos)
	
	#Corners
	CornerWallMultimesh.multimesh.instance_count = CornerWallMeshes.size()
	var CornerShape = CornerWallMultimesh.multimesh.mesh.create_trimesh_shape()
	CornerShape.backface_collision = true
	for g in CornerWallMeshes.size():
		var pos = CornerWallMeshes[g]
		
		var collision = CollisionShape3D.new()
		collision.shape = CornerShape
		WallCollission.add_child(collision)
		collision.transform = pos
		
		CornerWallMultimesh.multimesh.set_instance_transform(g, pos)
	
	#Dorr
	DoorWallMultimesh.multimesh.instance_count = DoorWallMeshes.size()
	for g in DoorWallMeshes.size():

		var pos = DoorWallMeshes[g]
		DoorWallMultimesh.multimesh.set_instance_transform(g, pos)

#old randomised generator
func _build_maze(maze):
	var width = maze.size()
	var height = maze[0].size()
	for y in range(height):
		for x in range(width):
			var cell = maze[y][x]
			var cell_pos = Vector3(x * cell_size, 0, y * cell_size)
			
			# Make floor
			var fl = MeshInstance3D.new()
			fl.mesh = PlaneMesh.new()
			fl.position = cell_pos
			add_child(fl)
			
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
