extends PanelContainer

class_name CharacterSheet

@export var CharacterNameLabel : Label
@export var CharacterLevelLabel : Label
@export var CharacterStatLabel : Label
@export var CharacterHealthBar : ProgressBar
@export var CharacterExpBar : ProgressBar
@export var AtackBar : ProgressBar


func SetCharacter(Char : Character) -> void:
	Char.Init()
	CharacterNameLabel.text = Char.CharacterName
	CharacterLevelLabel.text = "Lvl : {0}".format([Char.CharacterLevel])
	
	var stattext : String = ""
	for g in CharacterStat.STATS.values():
		stattext += "{0} : {1}".format([CharacterStat.STATS.keys()[g], Char.GetStat(g)])
		if (g < CharacterStat.STATS.keys().size() - 1):
			stattext += "\n"
	CharacterStatLabel.text = stattext
	
	CharacterHealthBar.max_value = Char.GetStat(CharacterStat.STATS.MAX_HP)
	CharacterHealthBar.value = Char.CurrentHP
	
	CharacterExpBar.max_value = Char.CharacterLevel * 100
	CharacterExpBar.value = Char.CurrentExp
	
	Char.LevelChanged.connect(LevelGained)
	Char.ExpGained.connect(StatsUpdated.bind(Char))
	Char.Damaged.connect(Damaged.bind(Char))
	Char.Killed.connect(CharacterKilled)
	Char.Atacked.connect(Atacked)
	Char.AtackProcessed.connect(AtackProcessed)

func AtackProcessed(TimeLeft : float) -> void:
	AtackBar.value = TimeLeft

func CharacterKilled() -> void:
	queue_free()

func Damaged(Amm : int, Char : Character) -> void:
	var f = Floater.new()
	f.text = var_to_str(Amm)
	add_child(f)
	f.SetColor(false)
	StatsUpdated(Char)
	
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "modulate", Color(1.0, 0.539, 0.475, 1.0), 0.15)
	await tw.finished
	var tw2 = create_tween()
	tw2.set_ease(Tween.EASE_OUT)
	tw2.set_trans(Tween.TRANS_BACK)
	tw2.tween_property(self, "modulate", Color(1,1,1), 0.15)
	
	AudioManager.Instance.PlaySound(AudioManager.Sound.DAMAGE, -5, 0.2)

func Atacked(_Damage : int) -> void:
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position", Vector2(position.x, position.y - 20), 0.15)
	await tw.finished
	var tw2 = create_tween()
	tw2.set_ease(Tween.EASE_OUT)
	tw2.set_trans(Tween.TRANS_BACK)
	tw2.tween_property(self, "position", Vector2(position.x, position.y + 20), 0.15)

func LevelGained() -> void:
	var f = Floater.new()
	f.text = "Level Up"
	add_child(f)
	AudioManager.Instance.PlaySound(AudioManager.Sound.LEVELUP, -5)

func StatsUpdated(Char : Character) -> void:
	CharacterLevelLabel.text = "Lvl : {0}".format([Char.CharacterLevel])
	
	var stattext : String = ""
	for g in CharacterStat.STATS.values():
		stattext += "{0} : {1}".format([CharacterStat.STATS.keys()[g], Char.GetStat(g)])
		if (g < CharacterStat.STATS.keys().size() - 1):
			stattext += "\n"
	
	CharacterStatLabel.text = stattext
	CharacterHealthBar.value = Char.CurrentHP
	
	CharacterExpBar.max_value = Char.CharacterLevel * 100
	CharacterExpBar.value = Char.CurrentExp


func _on_mouse_entered() -> void:
	CharacterStatLabel.visible = true


func _on_mouse_exited() -> void:
	CharacterStatLabel.visible = false
