extends Node
const LEVEL_WIDTH := 50
const LEVEL_HEIGHT := 10
const TILE_SIZE := 64
const PLATFORM_LENGTH_RANGE := [20, 30]
const GAP_LENGTH_RANGE := [15, 20]
var STAIRCASE_RANGE := [8, 15]
var STAIRCASE_THICKNESS_RANGE := [1, 3]
@onready var tilemap = get_node("TileMapLayer")


func _ready():
    if not tilemap:
        print("TileMapLayer not found!")
        return
    tilemap.clear()
    generate_level()


func generate_platform(start_pos: Vector2i, dimensions: Vector2i) -> int:
    var tile_columns = 0
    var platform_length = dimensions.x
    var layers = dimensions.y
    var x = start_pos.x
    var y = start_pos.y
    for layer in range(layers):
        for column in range(platform_length):
            var is_edge_column = column == 0 or column == platform_length - 1
            var is_edge_layer = layer == 0 or layer == layers - 1
            var atlas = Vector2i((((
                    0 if column == 0 else 2  # edges
                ) if is_edge_column else 1  # middle
            ) if platform_length > 1 else 3  # single tile
            ), ((
                    0 if layer == 0 else 2  # edges
                ) if is_edge_layer else 1  # middle
            ) if layers > 1 else 3  # single layer
            )
            tilemap.set_cell(
                Vector2i(x + column, y + layer),
                0,
                Vector2i(atlas.x, atlas.y),
                0
            )
            tile_columns += 1
    # return x changed
    return tile_columns


func get_beginning_landing_tile(column: int, row: int, landing_length: int, thickness: int) -> Vector2i:
    var x = (
        2 if column == 0
        else (0 if column == landing_length - 1
        else 1)
    )
    var y = (
        3 if thickness == 1
        else (0 if row == 0
        else (2 if row == thickness - 1
        else 1))
    )
    return Vector2i(x, y)


func get_step_tile(col: int, row: int, steps: int, thickness: int, is_ascending: bool, landing_length: int = 0) -> Vector2i:
    var x = (
        2 if col == 0 and thickness == 1 else
        3 if thickness == 1 else
        # If ascending, top row and first step, x = 1
        (1 if is_ascending and row == 0 and col == 0 else
        # First step, no landing, top row OR any step, top row
        (0 if is_ascending else 2) if (
            (col == 0 and landing_length == 0 and row == 0) or
            (row == 0)
        )
        # Last step, no landing, bottom row OR any step, bottom row
        else (
            # Special case: bottom row of first step and is_ascending is false
            1 if (col == 0 and row == thickness - 1 and not is_ascending)
            else (
                (2 if is_ascending else 0) if (
                    (col == steps - 1 and landing_length == 0 and row == thickness - 1) or
                    (row == thickness - 1)
                )
                # Middle tiles
                else 1
            )
        ))
    )
    var y = (
        3 if thickness == 1
        else (0 if row == 0
        else (2 if row == thickness - 1
        else 1))
    )

    return Vector2i(x, y)


func get_ending_landing_tile(row: int, column: int, landing_length: int, thickness: int, is_ascending: bool) -> Vector2i:
    var x = (
        # If not ascending, bottom row and first column, x = 0
        0 if (not is_ascending and row == thickness - 1 and column == 0)
        else (
            1 if (not is_ascending and row == 0 and column == 0)
            else (
                0 if (row == 0 and column == 0)
                else (
                    2 if column == landing_length - 1
                    else 1
                )
            )
        )
    )
    var y = (
        3 if thickness == 1
        else (0 if row == 0
        else (2 if row == thickness - 1
        else 1))
    )

    return Vector2i(x, y)


func generate_staircase(start_pos: Vector2i, steps: int, thickness: int, is_ascending: bool, landing_length: int = 5) -> int:
    var tile_columns = 0
    var x = start_pos.x - landing_length - 1
    var y = start_pos.y

    # generate beginning landing
    for column in range(landing_length):
        for row in range(thickness):
            var tile = get_beginning_landing_tile(column, row, landing_length, thickness)
            tilemap.set_cell(Vector2i(x - column, y + row), 0, tile, 0)

    # generate steps
    for i in range(steps):
        for j in range(thickness):
            var tile = get_step_tile(i, j, steps, thickness, is_ascending, landing_length)
            tilemap.set_cell(Vector2i(x + i, y + (-i if is_ascending else i) + j), 0, tile, 0)
        tile_columns += 1

    # generate ending landing
    for column in range(landing_length):
        for row in range(thickness):
            var tile = get_ending_landing_tile(row, column, landing_length, thickness, is_ascending)
            tilemap.set_cell(Vector2i(x + steps + column, y + (-steps if is_ascending else steps) + row), 0, tile, 0)

    return tile_columns


func generate_level():
    var y_base = int(float(LEVEL_HEIGHT) / 2.0)
    var x = -10
    var max_tiles = 10000  # Set a large number for "infinite" generation
    var tiles_placed = 0

    # Always generate a 20 tile long platform as the first platform
    x += generate_platform(Vector2i(x, y_base), Vector2i(20, 1))
    tiles_placed += 20

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
                tiles_placed += generate_platform(Vector2i(x, y), Vector2i(platform_length, y_variation + 1))
                x += platform_length
            1:  # Staircase up
                var steps = randi() % (STAIRCASE_RANGE[1] - STAIRCASE_RANGE[0] + 1) + STAIRCASE_RANGE[0]
                var thickness = randi() % (STAIRCASE_THICKNESS_RANGE[1] - STAIRCASE_THICKNESS_RANGE[0] + 1) + STAIRCASE_THICKNESS_RANGE[0]
                var y = clamp(y_base, 1, LEVEL_HEIGHT - steps - 1)
                tiles_placed += generate_staircase(Vector2i(x, y), steps, thickness, true)
                x += steps
            2:  # Staircase down
                var steps = randi() % (STAIRCASE_RANGE[1] - STAIRCASE_RANGE[0] + 1) + STAIRCASE_RANGE[0]
                var thickness = randi() % (STAIRCASE_THICKNESS_RANGE[1] - STAIRCASE_THICKNESS_RANGE[0] + 1) + STAIRCASE_THICKNESS_RANGE[0]
                var y = clamp(y_base, steps + 1, LEVEL_HEIGHT - 2)
                tiles_placed += generate_staircase(Vector2i(x, y), steps, thickness, false)
                x += steps
            3:  # Floating platform
                var platform_length = int((randi() % (PLATFORM_LENGTH_RANGE[1] - PLATFORM_LENGTH_RANGE[0] + 1) + PLATFORM_LENGTH_RANGE[0]) / 2.0)
                var y = clamp(y_base + randi() % 4 - 2, 2, LEVEL_HEIGHT - 3)
                tiles_placed += generate_platform(Vector2i(x, y), Vector2i(platform_length, 1))
                x += platform_length

        var gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
        x += gap


signal sense_direction_changed(direction: String)
func _on_terminal_sense_direction_changed(direction: String) -> void:
    emit_signal("sense_direction_changed", direction)
