extends Resource

class_name MonsterHouse

@export var Tiles : Array
@export var Spawns : Array[MonsterGroup]

signal Atack(Instigator : Monster, Damage : int)
signal MonsterKilled(Mon : Monster, ExpReward : int, GoldReward : int)
signal HouseCleared

func AddMonster(Mon : Monster) -> void:
	for g in Spawns:
		if (g.Mon == Mon and g.Ammount < 5):
			g.Ammount += 1
			return
	
	var newgroup = MonsterGroup.new()
	newgroup.Mon = Mon
	newgroup.Ammount = 1
	newgroup.Init()
	Spawns.append(newgroup)
	
	newgroup.Atacked.connect(GroupAtacks)
	newgroup.GroupKilled.connect(GroupKilled.bind(newgroup))
	newgroup.Killed.connect(MonKilled.bind(newgroup.Mon, newgroup.Mon.ExpReward, newgroup.Mon.GoldReward))

func ProcessHouse(delta : float) -> void:
	for g in Spawns:
		g.ProcessAtack(delta)

func GroupAtacks(Instigator : Monster, Damage : int) -> void:
	Atack.emit(Instigator, Damage)

func MonKilled(Mon : Monster, ExpReward : int, GoldReward : int) -> void:
	MonsterKilled.emit(Mon, randf_range(ExpReward * 0.8, ExpReward * 1.2), randf_range(GoldReward * 0.8, GoldReward * 1.2))

func GroupKilled(MonGroup : MonsterGroup) -> void:
	Spawns.erase(MonGroup)
	if (Spawns.size() == 0):
		HouseCleared.emit()
