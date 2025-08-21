extends Sprite2D


func _on_sense_direction_changed(direction: String) -> void:
    match direction:
        "north":
            rotation = deg_to_rad(90)
        "north-east":
            rotation = deg_to_rad(45)
        "east":
            rotation = deg_to_rad(0)
        "south-east":
            rotation = deg_to_rad(-10)
        "south":
            rotation = deg_to_rad(-90)
        "south-west":
            rotation = deg_to_rad(135)
        "west":
            rotation = deg_to_rad(180)
        "north-west":
            rotation = deg_to_rad(-135)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("debug_rotate_beam_clockwise"):
        rotation += deg_to_rad(45)
    if Input.is_action_just_pressed("debug_rotate_beam_anticlockwise"):
        rotation -= deg_to_rad(45)
