extends Node

class_name Main

@export var StartingCharacters : Array[Character]
@export var CharacterSheetScene : PackedScene
@export var MonsterSheetScene : PackedScene
@export var CharacterSheetPlecement : Control
@export var MonsterSheetPlecement : Control
@export var PlayerControllerScene : PackedScene

@export var MapScene : PackedScene
@export var Lvl : Level

@export var MiniMp : Minimap

var AliveCharacters : Array[Character]

var MapData : Map
var CurrentMosterHouse : MonsterHouse

func _ready() -> void:
	MapData = MapScene.instantiate() as Map
	add_child(MapData)
	
	for g in StartingCharacters:
		var newchar = g.duplicate()
		AliveCharacters.append(newchar)
		var newSheet = CharacterSheetScene.instantiate() as CharacterSheet
		newSheet.SetCharacter(newchar)
		newchar.Atacked.connect(AtackMonsters.bind(newchar))
		newchar.Killed.connect(CharacterKilled.bind(newchar))
		CharacterSheetPlecement.add_child(newSheet)
	
	Lvl.BuildMaze(MapData.maze, MapData.SpawnPoint)
	
	var Pl = PlayerControllerScene.instantiate() as Player
	
	Lvl.SpawnPlayer(Pl)
	
	Pl.PositionChanged.connect(PlayerPositionChanged)
	
	MiniMp.maze = MapData.maze

func PlayerPositionChanged(PlayerPosition : Vector3, PlayerOrientation : float) -> void:
	var pos = Vector2(roundi((PlayerPosition.x * 8) / 16), roundi((PlayerPosition.z * 8) / 16))
	var final = Vector2(pos.x * 16, pos.y * 16) + Vector2(8,8)
	
	MiniMp.OnPositionVisited(final, PlayerOrientation)
	
	@warning_ignore("narrowing_conversion")
	var MHouse = MapData.GetMonsterHouseForPosition(Vector2i(PlayerPosition.x, PlayerPosition.z) / 2)
	
	if (MHouse != CurrentMosterHouse):
		if (CurrentMosterHouse != null):
			CurrentMosterHouse.Atack.disconnect(AtackPlayers)
			CurrentMosterHouse.MonsterKilled.disconnect(MonsterKilled)
			#CurrentMosterHouse.HouseCleared.disconnect(MonsterHouseCleared)
			for g in MonsterSheetPlecement.get_children():
				g.queue_free()
		CurrentMosterHouse = MHouse
		if (CurrentMosterHouse != null):
			CurrentMosterHouse.Atack.connect(AtackPlayers)
			CurrentMosterHouse.MonsterKilled.connect(MonsterKilled)
			#CurrentMosterHouse.HouseCleared.connect(MonsterHouseCleared.bind(CurrentMosterHouse))
			for g in CurrentMosterHouse.Spawns:
				var MonSheet = MonsterSheetScene.instantiate() as MonsterSheet
				MonsterSheetPlecement.add_child(MonSheet)
				MonSheet.AddMonsters(g)
				
func _physics_process(delta: float) -> void:
	if (CurrentMosterHouse == null or CurrentMosterHouse.Spawns.size() == 0):
		return
	CurrentMosterHouse.ProcessHouse(delta)
	
	for g in AliveCharacters:
		g.ProcessAtack(delta)

func MonsterKilled(Mon : Monster, ExpReward : int) -> void:
	MessageBox.RegisterEvent("A {0} was killed. +{1} exp".format([Mon.MonsterName, ExpReward]))
	for g in AliveCharacters:
		g.GiveExp(ExpReward)
	

func CharacterKilled(Char : Character) -> void:
	AliveCharacters.erase(Char)
	MessageBox.RegisterEvent("{0} was killed".format([Char.CharacterName]))
	if (AliveCharacters.size() == 0):
		get_tree().quit()

func AtackPlayers(Instigator : Monster, Damage : int) -> void:
	var target = AliveCharacters.pick_random()
	target.Damage(Instigator, Damage)

func AtackMonsters(Damage : int, Instigator : Character) -> void:
	var target = CurrentMosterHouse.Spawns.pick_random() as MonsterGroup
	
	target.Damage(Instigator, Damage)
