extends Resource

class_name Character

@export var CharacterName : String
@export var CharacterLevel : int = 1
@export var CharacterStats : Array[CharacterStat]

signal LevelChanged

func LevelUp() -> void:
	CharacterLevel += 1
	LevelChanged.emit()

func GetStat(StatName : CharacterStat.STATS) -> int:
	return CharacterStats[StatName].LevelMulti * CharacterLevel
