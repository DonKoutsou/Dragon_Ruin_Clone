extends Resource

class_name MonsterGroup

@export var Mon : Monster
@export var Ammount : int = 0

signal Atacked(Instigator : Monster, Damage : int)
signal Damaged(Amm : int)
signal Killed
signal GroupKilled

var CurrentHP : int = 0

var AtackCooldown : float = 1

func ProcessAtack(delta : float) -> void:
	AtackCooldown -= Mon.GetStat(CharacterStat.STATS.SPD) / 100.0 * delta
	if (AtackCooldown <= 0):
		AtackCooldown = 1
		Atacked.emit(Mon, Mon.GetStat(CharacterStat.STATS.AT))
		
func Init() -> void:
	CurrentHP = Mon.GetStat(CharacterStat.STATS.MAX_HP)

func Damage(Instigator : Character, Amm : int) -> void:
	var finalDamage = max(0, Amm - Mon.GetStat(CharacterStat.STATS.DEF))
	CurrentHP -= finalDamage
	
	MessageBox.RegisterEvent("{0} atacked {1} for {2} damage".format([Instigator.CharacterName, Mon.MonsterName, finalDamage]))
	
	Damaged.emit(finalDamage)
	
	if (CurrentHP <= 0):
		Killed.emit()
		CurrentHP = Mon.GetStat(CharacterStat.STATS.MAX_HP)
		Ammount -= 1
		if (Ammount == 0):
			GroupKilled.emit()
