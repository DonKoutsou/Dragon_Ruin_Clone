extends Resource

class_name Monster

@export var MonsterName : String
@export var MonsterStats : Array[CharacterStat]
@export var ExpReward : int = 1
@export var GoldReward : int = 1

func GetStat(StatName : CharacterStat.STATS) -> int:
	return MonsterStats[StatName].StartingValue
