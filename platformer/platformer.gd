extends Node
const LEVEL_WIDTH := 50
const LEVEL_HEIGHT := 10
const TILE_SIZE := 64
const PLATFORM_LENGTH_RANGE := [3, 8]
const GAP_LENGTH_RANGE := [2, 5]


func _ready():
    generate_level()


func generate_level():
    var tilemap = get_node_or_null("TileMapLayer")
    if not tilemap:
        print("TileMapLayer not found!")
        return
    tilemap.clear()

    var y_base = float(LEVEL_HEIGHT) / 2
    var x = 0
    while x < LEVEL_WIDTH:
        # Random platform length
        var platform_length = randi() % (PLATFORM_LENGTH_RANGE[1] - PLATFORM_LENGTH_RANGE[0] + 1) + PLATFORM_LENGTH_RANGE[0]
        # Random vertical offset
        var y_offset = randi() % 3 - 1  # -1, 0, or 1
        var y = clamp(y_base + y_offset, 1, LEVEL_HEIGHT - 2)
        # Place platform tiles
        for i in range(platform_length):
            if x + i >= LEVEL_WIDTH:
                break
            # Use tile source_id=0, atlas_coords=Vector2i(0, 0), alternative_tile=0
            tilemap.set_cell(Vector2i(x + i, y), 0, Vector2i(0, 0), 0)
        x += platform_length
        # Random gap
        var gap = randi() % (GAP_LENGTH_RANGE[1] - GAP_LENGTH_RANGE[0] + 1) + GAP_LENGTH_RANGE[0]
        x += gap

    # Optionally, add ground at the bottom
    for gx in range(LEVEL_WIDTH):
        tilemap.set_cell(Vector2i(gx, LEVEL_HEIGHT - 1), 0, Vector2i(0, 0), 0)


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
