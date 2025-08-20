extends TabContainer

@onready var surroundings: Node = get_node("Surroundings/SubViewportContainer/SubViewport/Node")
@onready var terminal: Node = get_node("Terminal/SubViewportContainer/SubViewport/Node")

func _ready():
    set_current_tab(0)
    surroundings.process_mode = Node.PROCESS_MODE_INHERIT
    terminal.get_node("Entry").line_edit.release_focus()
    terminal.process_mode = Node.PROCESS_MODE_DISABLED



# pause only the "Surroundings" node and its children when this tab is active
func _on_tab_changed(new_tab: int):
    if get_tab_title(new_tab) == "Terminal":
        surroundings.process_mode = Node.PROCESS_MODE_DISABLED
        terminal.get_node("Entry").line_edit.grab_focus()
        terminal.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        surroundings.process_mode = Node.PROCESS_MODE_INHERIT
        terminal.get_node("Entry").line_edit.release_focus()
        terminal.process_mode = Node.PROCESS_MODE_DISABLED
