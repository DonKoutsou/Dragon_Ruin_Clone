extends Node

class_name AudioManager

@export var SoundLibrary : Dictionary[Sound, AudioStream]

static var Instance : AudioManager

func _ready() -> void:
	Instance = self

func PlaySound(S : Sound, volume : float = 0, RandPitchAmm : float = 0) -> void:
	var Audio = SoundLibrary[S]
	var DeletableS = DeletableSound.new()
	add_child(DeletableS)
	DeletableS.stream = Audio
	DeletableS.pitch_scale = randf_range(1 - RandPitchAmm, 1 + RandPitchAmm)
	DeletableS.volume_db = volume
	DeletableS.play()

enum Sound{
	STEP,
	LEVELUP,
	DAMAGE,
}
