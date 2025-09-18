extends PanelContainer

class_name MessageBox

static var TextContainer : Label

static var Events : Array[String]

func _ready() -> void:
	TextContainer = get_child(0)

static func RegisterEvent(EventText : String) -> void:
	Events.push_back(EventText)
	if (Events.size() > 10):
		Events.pop_front()
	
	var finaltext : String = ""
	for g in Events.size():
		finaltext += Events[g]
		if (g < Events.size() -1):
			finaltext += "\n"
			
	TextContainer.text = finaltext
