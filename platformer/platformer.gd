extends Node
const LEVEL_WIDTH := 50
const LEVEL_HEIGHT := 10
const TILE_SIZE := 64
const PLATFORM_LENGTH_RANGE := [20, 30]
const GAP_LENGTH_RANGE := [20, 30]

var tilemap: TileMapLayer = null
var player: Node2D = null
var last_generated_x: int = 0


func _ready():
    tilemap = get_node_or_null("TileMapLayer")
    player = get_node_or_null("Player")
    if not tilemap:
        print("TileMapLayer not found!")
        return
    if not player:
        print("Player not found!")
        return
    tilemap.clear()
    last_generated_x = -10
    _generate_initial_platform()
    set_process(true)


func _generate_initial_platform():
    var y_base = float(LEVEL_HEIGHT) / 2
    var x = last_generated_x
    var first_platform_length = 20
    var first_y = clamp(y_base, 1, LEVEL_HEIGHT - 2)
    for i in range(first_platform_length):
        tilemap.set_cell(Vector2i(x + i, first_y), 0)
    x += first_platform_length
    var next_gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
    x += next_gap
    last_generated_x = x


func _generate_platforms_until(x_target: int):
    var y_base = float(LEVEL_HEIGHT) / 2
    var x = last_generated_x
    while x < x_target:
        var structure_type = randi() % 4
        match structure_type:
            0:  # Standard platform
                var platform_length = randi() % (PLATFORM_LENGTH_RANGE[1] - PLATFORM_LENGTH_RANGE[0] + 1) + PLATFORM_LENGTH_RANGE[0]
                var y_offset = randi() % 3 - 1
                var y = clamp(y_base + y_offset, 1, LEVEL_HEIGHT - 2)
                for i in range(platform_length):
                    tilemap.set_cell(Vector2i(x + i, y), 0)
                x += platform_length
            1:  # Staircase up
                var steps = randi() % 5 + 3
                var y = clamp(y_base, 1, LEVEL_HEIGHT - steps - 1)
                for i in range(steps):
                    tilemap.set_cell(Vector2i(x + i, y + i), 0)
                x += steps
            2:  # Staircase down
                var steps = randi() % 5 + 3
                var y = clamp(y_base, steps + 1, LEVEL_HEIGHT - 2)
                for i in range(steps):
                    tilemap.set_cell(Vector2i(x + i, y - i), 0)
                x += steps
            3:  # Floating platform
                var platform_length = randi() % 5 + 3
                var y = clamp(y_base + randi() % 4 - 2, 2, LEVEL_HEIGHT - 3)
                for i in range(platform_length):
                    tilemap.set_cell(Vector2i(x + i, y), 0)
                x += platform_length
        var gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
        x += gap
    last_generated_x = x


func _process(_delta):
    if not player:
        return
    var player_x = int(player.position.x / TILE_SIZE)
    var buffer = 50  # How far ahead to generate
    var x_target = player_x + buffer
    if x_target > last_generated_x:
        _generate_platforms_until(x_target)


@onready var beam: Sprite2D = get_node("Player/Beam")
func _on_terminal_sense_direction_changed(direction: String) -> void:
    match direction:
        "north":
            beam.rotation = deg_to_rad(-90)
        "north-east":
            beam.rotation = deg_to_rad(-45)
        "east":
            beam.rotation = deg_to_rad(0)
        "south-east":
            beam.rotation = deg_to_rad(45)
        "south":
            beam.rotation = deg_to_rad(90)
        "south-west":
            beam.rotation = deg_to_rad(135)
        "west":
            beam.rotation = deg_to_rad(180)
        "north-west":
            beam.rotation = deg_to_rad(-135)
