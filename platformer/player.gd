extends CharacterBody2D

const SPEED = 900.0
const JUMP_VELOCITY = -800.0
const MAX_JUMPS = 2

var jumps_left = MAX_JUMPS

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Reset jumps when on floor
    if is_on_floor():
        jumps_left = MAX_JUMPS

    # Handle jump and double jump
    if Input.is_action_just_pressed("move_up") and jumps_left > 0:
        velocity.y = JUMP_VELOCITY
        jumps_left -= 1

    # Get the input direction and handle the movement/deceleration.
    var direction := Input.get_axis("move_left", "move_right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
