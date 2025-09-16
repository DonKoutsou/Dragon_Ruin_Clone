extends PanelContainer

class_name CharacterSheet

@export var CharacterNameLabel : Label
@export var CharacterLevelLabel : Label
@export var CharacterStatLabel : Label

func SetCharacter(Char : Character) -> void:
	CharacterNameLabel.text = Char.CharacterName
	CharacterLevelLabel.text = "Lvl : {0}".format([Char.CharacterLevel])
	
	var stattext : String = ""
	for g in CharacterStat.STATS.values():
		stattext += "{0} : {1}".format([CharacterStat.STATS.keys()[g], Char.GetStat(g)])
		if (g < CharacterStat.STATS.keys().size() - 1):
			stattext += "\n"
			
	CharacterStatLabel.text = stattext
	
	Char.LevelChanged.connect(StatsUpdated.bind(Char))

func StatsUpdated(Char : Character) -> void:
	CharacterLevelLabel.text = "Lvl : {0}".format([Char.CharacterLevel])
	
	var stattext : String = ""
	for g in CharacterStat.STATS:
		stattext += "{0} : {1}".format([CharacterStat.STATS.keys()[g], Char.GetStat(g)])
		if (g < CharacterStat.STATS.keys().size() - 1):
			stattext += "\n"
	
	CharacterStatLabel.text = stattext
