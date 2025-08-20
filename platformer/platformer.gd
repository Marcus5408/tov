extends Node
const LEVEL_WIDTH := 50
const LEVEL_HEIGHT := 10
const TILE_SIZE := 64
const PLATFORM_LENGTH_RANGE := [20, 30]
const GAP_LENGTH_RANGE := [15, 20]
var STAIRCASE_RANGE := [8, 15]


func _ready():
    generate_level()


func generate_level():
    var tilemap = get_node_or_null("TileMapLayer")
    if not tilemap:
        print("TileMapLayer not found!")
        return
    tilemap.clear()

    var y_base = float(LEVEL_HEIGHT) / 2
    var x = -10
    var max_tiles = 10000  # Set a large number for "infinite" generation
    var tiles_placed = 0

    # Always generate a 20 tile long platform as the first platform
    var first_platform_length = 20
    var first_y = clamp(y_base, 1, LEVEL_HEIGHT - 2)
    for i in range(first_platform_length):
        tilemap.set_cell(Vector2i(x + i, first_y), 0, Vector2i(0, 0), 0)
        tiles_placed += 1
    x += first_platform_length

    # Add a gap after the first platform
    var next_gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
    x += next_gap

    while tiles_placed < max_tiles:
        var structure_type = randi() % 4
        match structure_type:
            0:  # Standard platform
                var platform_length = randi() % (PLATFORM_LENGTH_RANGE[1] - PLATFORM_LENGTH_RANGE[0] + 1) + PLATFORM_LENGTH_RANGE[0]
                var y_offset = randi() % 3 - 1
                var y = clamp(y_base + y_offset, 1, LEVEL_HEIGHT - 2)
                var y_variation = randi() % 2
                var is_edge_layer
                var is_edge_column
                for layer in range(y_variation + 1):
                    for column in range(platform_length):
                        is_edge_column = column == 0 or column == platform_length - 1
                        var atlas_x = ((
                                0 if column == 0 else 2  # edges
                            ) if is_edge_column else 1  # middle
                        ) if platform_length > 1 else 3  # single tile
                        # single tiles can't exist under default generation,
                        # but it's here for when I eventually add customizable
                        # platform lengths and some guy decides to set a minimum
                        # platform length of 1.
                        is_edge_layer = layer == 0 or layer == y_variation
                        var atlas_y = ((
                                0 if layer == 0 else 2  # edges
                            ) if is_edge_layer else 1  # middle
                        ) if y_variation > 0 else 3  # single layer
                        tilemap.set_cell(
                            Vector2i(x + column, y + layer),
                            0,
                            Vector2i(atlas_x, atlas_y),
                            0
                        )
                        tiles_placed += 1
                x += platform_length
            1:  # Staircase up
                var steps = randi() % (STAIRCASE_RANGE[1] - STAIRCASE_RANGE[0] + 1) + STAIRCASE_RANGE[0]
                var y = clamp(y_base, 1, LEVEL_HEIGHT - steps - 1)
                for i in range(steps):
                    tilemap.set_cell(Vector2i(x + i, y + i), 0, Vector2i(0, 0), 0)
                    tiles_placed += 1
                x += steps
            2:  # Staircase down
                var steps = randi() % (STAIRCASE_RANGE[1] - STAIRCASE_RANGE[0] + 1) + STAIRCASE_RANGE[0]
                var y = clamp(y_base, steps + 1, LEVEL_HEIGHT - 2)
                for i in range(steps):
                    tilemap.set_cell(Vector2i(x + i, y - i), 0, Vector2i(0, 0), 0)
                    tiles_placed += 1
                x += steps
            3:  # Floating platform

                var platform_length = int((randi() % (PLATFORM_LENGTH_RANGE[1] - PLATFORM_LENGTH_RANGE[0] + 1) + PLATFORM_LENGTH_RANGE[0]) / 2.0)
                var y = clamp(y_base + randi() % 4 - 2, 2, LEVEL_HEIGHT - 3)
                for i in range(platform_length):
                    tilemap.set_cell(Vector2i(x + i, y), 0, Vector2i(0, 0), 0)
                    tiles_placed += 1
                x += platform_length

        var gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
        x += gap


@onready var beam: Sprite2D = get_node("Player/Beam")
func _on_terminal_sense_direction_changed(direction: String) -> void:
    match direction:
        "north":
            beam.rotation = deg_to_rad(90)
        "north-east":
            beam.rotation = deg_to_rad(45)
        "east":
            beam.rotation = deg_to_rad(0)
        "south-east":
            beam.rotation = deg_to_rad(-10)
        "south":
            beam.rotation = deg_to_rad(-90)
        "south-west":
            beam.rotation = deg_to_rad(135)
        "west":
            beam.rotation = deg_to_rad(180)
        "north-west":
            beam.rotation = deg_to_rad(-135)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("debug_rotate_beam_clockwise"):
        beam.rotation += deg_to_rad(45)
    if Input.is_action_just_pressed("debug_rotate_beam_anticlockwise"):
        beam.rotation -= deg_to_rad(45)
