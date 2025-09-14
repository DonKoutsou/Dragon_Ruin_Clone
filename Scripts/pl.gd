# Player.gd (character body with camera as child)
extends Camera3D

class_name Player

static var PlayerPos : Vector3

@export var speed = 4.0
@export var Cast : RayCast3D

var LookDir : Vector3

var MoveTween : Tween
var RotTween : Tween

func Teleport(Pos : Vector3) -> void:
	PlayerPos = Pos
	position = PlayerPos

func _physics_process(delta):
	
	HandleRotation()
	HandleWalk()
	

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
	
	Minimap.instance.OnPositionVisited(PlayerPos, LookDir.y)


func HandleWalk() -> void:
	if (is_instance_valid(MoveTween) and MoveTween.is_running()):
		return
		
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
	
	Cast.target_position = dir * 2
	
	dir = dir.normalized().rotated(Vector3(0,1,0), LookDir.y)
	
	
	Cast.force_raycast_update()
	if (Cast.is_colliding()):
		return
	PlayerPos += (dir * 2)
	
	MoveTween = create_tween()
	MoveTween.tween_property(self, "position", PlayerPos, 0.3)
	
	Minimap.instance.OnPositionVisited(PlayerPos, LookDir.y)
