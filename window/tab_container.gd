extends TabContainer

# pause only the "Surroundings" node and its children when this tab is active
func _on_tab_changed(new_tab: int):
    var surroundings: Node = get_node("Surroundings/SubViewportContainer/SubViewport/Node")
    if get_tab_title(new_tab) == "Terminal":
        surroundings.process_mode = Node.PROCESS_MODE_DISABLED
    else:
        surroundings.process_mode = Node.PROCESS_MODE_INHERIT
