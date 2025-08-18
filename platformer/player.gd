extends CharacterBody2D
const SPEED = 900.0
const JUMP_VELOCITY = -800.0
const MAX_JUMPS = 2

var jumps_left = MAX_JUMPS

const SPAWN_POSITION = Vector2(0, 0)  # Set your spawn position here


func _ready():
    spawn_player()


func spawn_player():
    self.position = SPAWN_POSITION
    self.velocity = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
var prev_direction: float = 0.0
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
        sprite.flip_h = direction < 0
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()

func _on_void_body_entered(body:Node2D) -> void:
    if body == self:
        spawn_player()
