extends Node

class_name Main

@export var StartingCharacters : Array[Character]
@export var CharacterSheetScene : PackedScene
@export var CharacterSheetPlecement : Control

@export var PlayerControllerScene : PackedScene

@export var MapScene : PackedScene
@export var Lvl : Level

@export var MiniMp : Minimap

func _ready() -> void:
	var TileMS = MapScene.instantiate() as Map
	add_child(TileMS)
	
	for g in StartingCharacters:
		var newSheet = CharacterSheetScene.instantiate() as CharacterSheet
		newSheet.SetCharacter(g)
		CharacterSheetPlecement.add_child(newSheet)
	
	Lvl.BuildMaze(TileMS.maze, TileMS.SpawnPoint)
	
	var Pl = PlayerControllerScene.instantiate() as Player
	
	Lvl.SpawnPlayer(Pl)
	
	Pl.PositionChanged.connect(PlayerPositionChanged)
	
	MiniMp.maze = TileMS.maze

func PlayerPositionChanged(PlayerPosition : Vector3, PlayerOrientation : float) -> void:
	MiniMp.OnPositionVisited(PlayerPosition, PlayerOrientation)
