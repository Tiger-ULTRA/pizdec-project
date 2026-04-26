extends CharacterBody3D
class_name Player

# MOVEMENT
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func update_readiness_indicator(_value: bool) -> void:
	if not is_multiplayer_authority(): return
	$ReadinessIndicator.frame = ($ReadinessIndicator.frame + 1) % 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toogle_readiness"):
		update_readiness_indicator(1)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backfard")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var target_rotation = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 15 * delta)
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
