extends Camera2D

@onready var background: ColorRect = get_node("ColorRect")

func _process(_delta: float) -> void:
    background.set_anchors_preset(Control.PRESET_CENTER)
    # Use the smoothed camera position for background alignment
    background.global_position = get_screen_center_position() - background.size / 2
