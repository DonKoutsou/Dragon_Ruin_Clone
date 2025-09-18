extends PanelContainer

class_name MonsterSheet

@export var MonsterNameLabel : Label
@export var MonsterAmountLabel : Label
@export var MonsterStatLabel : Label

var MonsterAmm : int

func AddMonsters(MonGroup : MonsterGroup) -> void:
	MonsterNameLabel.text = MonGroup.Mon.MonsterName
	
	MonsterAmm = MonGroup.Ammount
	MonsterAmountLabel.text = "{0}".format([MonsterAmm])
	
	MonGroup.Damaged.connect(MonsterDamaged)
	MonGroup.Killed.connect(MonsterKilled)
	MonGroup.Atacked.connect(MonsterAtacked)
	
	var stattext : String = ""
	for g in CharacterStat.STATS.values():
		stattext += "{0} : {1}".format([CharacterStat.STATS.keys()[g], MonGroup.Mon.GetStat(g)])
		if (g < CharacterStat.STATS.keys().size() - 1):
			stattext += "\n"
	MonsterStatLabel.text = stattext


func MonsterDamaged(Amm : int) -> void:
	var f = Floater.new()
	f.text = var_to_str(Amm)
	add_child(f)
	f.SetColor(false)
	
	
func MonsterKilled() -> void:
	MonsterAmm -= 1
	MonsterAmountLabel.text = "{0}".format([MonsterAmm])
	if (MonsterAmm == 0):
		var tw = create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "modulate", Color(1,1,1,0), 1)
		await tw.finished
		
		queue_free()


func MonsterAtacked(_Instigator : Monster, _Damage : int) -> void:
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position", Vector2(position.x, position.y - 20), 0.15)
	await tw.finished
	var tw2 = create_tween()
	tw2.set_ease(Tween.EASE_OUT)
	tw2.set_trans(Tween.TRANS_BACK)
	tw2.tween_property(self, "position", Vector2(position.x, position.y + 20), 0.15)


func _on_mouse_entered() -> void:
	MonsterStatLabel.visible = true


func _on_mouse_exited() -> void:
	MonsterStatLabel.visible = false
