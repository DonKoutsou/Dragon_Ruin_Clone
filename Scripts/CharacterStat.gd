extends Resource

class_name CharacterStat

@export var StatName : STATS
@export var StartingValue : int = 1
@export var LevelMulti : int = 1

enum STATS
{
	MAX_HP,
	AT,
	DEF,
	SPD,
}
