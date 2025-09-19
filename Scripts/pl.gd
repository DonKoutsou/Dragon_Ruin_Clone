# Player.gd (character body with camera as child)
extends Node3D

class_name Player

static var PlayerPos : Vector3

@export var speed = 4.0
@export var Cast : RayCast3D
@export var CamPivot : Node3D
@export var CamRotPivot : Node3D

var LookDir : Vector3

var MoveTween : Tween
var RotTween : Tween

signal PositionChanged(Pos : Vector3, Rot : float)

func Teleport(Pos : Vector3) -> void:
	PlayerPos = Pos
	position = PlayerPos
	PositionChanged.emit(PlayerPos, LookDir.y)

func _input(event: InputEvent) -> void:
	HandleRotation(event)
	HandleWalk(event)
	

func HandleRotation(event: InputEvent) -> void:
	var Rot : Vector3 = Vector3.ZERO
	
	if (event.is_action_pressed("look_left")):
		Rot.y += PI / 2
	if (event.is_action_pressed("look_right")):
		Rot.y -= PI / 2
	if (event.is_action_pressed("look_back")):
		Rot.y -= PI
		
	if (Rot == Vector3.ZERO):
		return
		
	LookDir += Rot
	
	if (is_instance_valid(RotTween)):
		RotTween.kill()
	RotTween = create_tween()
	RotTween.tween_property(CamRotPivot, "rotation", LookDir, 0.3)
	
	PositionChanged.emit(PlayerPos, LookDir.y)

func HandleWalk(event: InputEvent) -> void:
	var dir = Vector3.ZERO
	
	if event.is_action_pressed("move_forward"):
		dir.z -= 1
	if event.is_action_pressed("move_back"):
		dir.z += 1
	if event.is_action_pressed("move_left"):
		dir.x -= 1
	if event.is_action_pressed("move_right"):
		dir.x += 1
 	
	if (dir == Vector3.ZERO):
		return
	
	dir = dir.normalized().rotated(Vector3(0,1,0), LookDir.y)
	
	Cast.target_position = dir * 2
	
	Cast.force_raycast_update()
	if (Cast.is_colliding()):
		return
	PlayerPos += (dir * 2)
	PlayerPos = PlayerPos.round()
	
	if (is_instance_valid(MoveTween)):
		MoveTween.kill()
	
	MoveTween = create_tween()
	MoveTween.tween_method(TweenCam.bind(CamPivot.global_position, PlayerPos), 0.0, 1.0, 0.3)
	#MoveTween.tween_property(CamPivot, "global_position", PlayerPos, 0.3)
	position = PlayerPos
	
	PositionChanged.emit(PlayerPos, LookDir.y)
	
	AudioManager.Instance.PlaySound(AudioManager.Sound.STEP, -5, 0.2)

func TweenCam(Alpha : float, OriginalPosition : Vector3, FinalPos : Vector3) -> void:
	CamPivot.global_position = OriginalPosition.lerp(FinalPos, Alpha)
