extends Label

class_name Floater


var GoodColor : Color = Color(0.311, 0.626, 0.0, 1.0)
var BadColor : Color = Color(1.0, 0.282, 0.178, 1.0)


signal Ended
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	call_deferred("DoThing")

func DoThing() -> void:
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position", Vector2(position.x, position.y - 40), 0.75)
	await tw.finished
	Ended.emit()
	queue_free()

func SetColor(Good : bool) -> void:
	if (Good):
		modulate = GoodColor
	else:
		modulate = BadColor
