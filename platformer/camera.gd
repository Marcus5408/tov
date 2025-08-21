extends Camera2D

@onready var background: ColorRect = get_node("ColorRect")
@onready var player_void: CollisionShape2D = self.get_parent().get_parent().get_node("Void/CollisionShape2D")

func _process(_delta: float) -> void:
    background.set_anchors_preset(Control.PRESET_CENTER)
    background.global_position = get_screen_center_position() - background.size / 2

    player_void.transform.origin.x = get_screen_center_position().x
