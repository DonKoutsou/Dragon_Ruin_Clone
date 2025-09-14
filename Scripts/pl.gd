# Player.gd (character body with camera as child)
extends Camera3D

class_name Player

static var PlayerPos : Vector3

@export var speed = 4.0

var LookDir : Vector3

var MoveTween : Tween
var RotTween : Tween

func Teleport(Pos : Vector3) -> void:
	PlayerPos = Pos
	position = PlayerPos

func _physics_process(delta):
	HandleWalk()
	HandleRotation()
	

func HandleRotation() -> void:
	var Rot : Vector3 = Vector3.ZERO
	
	if (Input.is_action_just_pressed("look_left")):
		Rot.y += PI / 2

	if (Input.is_action_just_pressed("look_right")):
		Rot.y -= PI / 2
	if (Input.is_action_just_pressed("look_back")):
		Rot.y -= PI
		
	if (Rot == Vector3.ZERO):
		return
	LookDir += Rot
	
	if (is_instance_valid(RotTween)):
		RotTween.kill()
	RotTween = create_tween()
	RotTween.tween_property(self, "rotation", LookDir, 0.3)
	
func HandleWalk() -> void:
	var dir = Vector3.ZERO
	if Input.is_action_just_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_just_pressed("move_back"):
		dir.z += 1
	if Input.is_action_just_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_just_pressed("move_right"):
		dir.x += 1
 	
	if (dir == Vector3.ZERO):
		return
	
	dir = dir.normalized().rotated(Vector3(0,1,0), LookDir.y)
	
	if (!Map.CanMoveToPos(((PlayerPos + (dir * 2))/2))):
		return
	PlayerPos += (dir * 2)
	
	if (is_instance_valid(MoveTween)):
		MoveTween.kill()
	
	MoveTween = create_tween()
	MoveTween.tween_property(self, "position", PlayerPos, 0.3)
	
	Minimap.instance.OnPositionVisited(PlayerPos)
