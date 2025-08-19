extends CharacterBody2D
const SPEED = 900.0
const JUMP_VELOCITY = -800.0
const MAX_JUMPS = 2

var jumps_left = MAX_JUMPS

const SPAWN_POSITION = Vector2(0, 0)  # Set your spawn position here


func _ready():
    spawn_player()
    # Add a shader to beam to taper opacity from 0.75 (center) to 0 (edge)
    var shader := Shader.new()
    shader.code = '''
        shader_type canvas_item;
        void fragment() {
            vec2 center = vec2(0.5, 0.5);
            float dist = distance(UV, center) / 0.075;
            float alpha = mix(0.0, 0.6, dist);
            COLOR = texture(TEXTURE, UV);
            COLOR.a *= alpha;
        }
    '''
    var mat := ShaderMaterial.new()
    mat.shader = shader
    beam.material = mat


func spawn_player():
    self.position = SPAWN_POSITION
    self.velocity = Vector2.ZERO


@onready var sprite: Sprite2D = $Sprite2D
@onready var beam: Sprite2D = $Beam
var prev_direction: float = 0.0
var beam_visible := true
func _physics_process(delta: float) -> void:
    # Toggle beam visibility with debug_toggle_beam
    if Input.is_action_just_pressed("debug_toggle_beam"):
        beam_visible = !beam_visible
        beam.visible = beam_visible

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
        if beam.rotation == deg_to_rad(0) or beam.rotation == deg_to_rad(180):
            # Only flip the beam if it's horizontal
            # This prevents flipping when sensing directions
            beam.flip_h = direction < 0
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    # cap velocity in both directions
    velocity.x = clamp(velocity.x, -SPEED, SPEED)
    velocity.y = clamp(velocity.y, -SPEED, SPEED)

    print(position)

    move_and_slide()


func _on_void_body_entered(body: Node2D) -> void:
    if body == self:
        spawn_player()
