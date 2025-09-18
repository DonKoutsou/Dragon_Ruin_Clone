extends Resource

class_name Character

@export var CharacterName : String
@export var CharacterLevel : int = 1
@export var CharacterStats : Array[CharacterStat]

signal Atacked
signal LevelChanged
signal ExpGained
signal Damaged(Amm : int)
signal Killed

var CurrentExp : int = 0
var CurrentHP : int = 0

func Init() -> void:
	CurrentHP = GetStat(CharacterStat.STATS.MAX_HP)

func GiveExp(Amm : int) -> void:
	CurrentExp += Amm
	if (CurrentExp > CharacterLevel * 100):
		CurrentExp -= CharacterLevel * 100
		LevelUp()
	ExpGained.emit()

func LevelUp() -> void:
	CharacterLevel += 1
	CurrentHP = GetStat(CharacterStat.STATS.MAX_HP)
	LevelChanged.emit()
	MessageBox.RegisterEvent("{0} leveled up".format([CharacterName]))

func Damage(Instigator : Monster, Amm : int) -> void:
	var finalDamage = max(0, Amm - GetStat(CharacterStat.STATS.DEF))
	CurrentHP -= finalDamage
	
	MessageBox.RegisterEvent("{0} atacked {1} for {2} damage".format([Instigator.MonsterName, CharacterName, finalDamage]))
	
	Damaged.emit(finalDamage)
	
	if (CurrentHP <= 0):
		Killed.emit()


func GetStat(StatName : CharacterStat.STATS) -> int:
	return CharacterStats[StatName].StartingValue + (CharacterStats[StatName].LevelMulti * CharacterLevel)

var AtackCooldown : float = 1

func ProcessAtack(delta : float) -> void:
	AtackCooldown -= GetStat(CharacterStat.STATS.SPD) / 100.0 * delta
	if (AtackCooldown <= 0):
		AtackCooldown = 1
		Atacked.emit(GetStat(CharacterStat.STATS.AT))
