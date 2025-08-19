extends Control

@onready var root: VBoxContainer = get_node("ScrollContainer/VBoxContainer")
var Entry = load("res://terminal/Entry.tscn")
var history: Array = []

func _ready():
    add_text("Last login: Tue Aug 19 1:11:58 on ttys000")
    add_text("Welcome to the Rover Terminal!")
    add_text("Type man <command> for more information.")
    add_text("Type `man terminal` for help using this terminal.")
    add_entry("Operator@Rover1 ~ % ")

func _process(_delta: float) -> void:
    pass

# --------
# Commands
# --------

func process_command(command: String):
    command = command.strip_edges()
    var args = command.split(" ")
    match args[0]:
        "clear":
            history.clear()
            rerender_history()
            add_entry("Operator@Rover1 ~ % ")
        "help":
            help()
        "neofetch":
            neofetch()
        "sense":
            var params = command.replace("sense ", "").strip_edges()
            sense(params)
        _:
            add_text("[color=red]Unknown command: %s[/color]" % command)

func neofetch():
    # fake neofetch !
    var text = ""
    var file = FileAccess.open("res://terminal/neofetch.bbcode", FileAccess.READ)
    if file:
        text = file.get_as_text()
        file.close()
        text += "\n\n"
    else:
        text = "[color=red]Failed to load `neofetch.bbcode`. Please contact support.[/color]"
    add_text(text)

signal sense_direction_changed(direction: String)
func sense(direction: String):
    match direction:
        "north":
            add_text("Sensing north...")
        "north-east":
            add_text("Sensing north-east...")
        "east":
            add_text("Sensing east...")
        "south-east":
            add_text("Sensing south-east...")
        "south":
            add_text("Sensing south...")
        "south-west":
            add_text("Sensing south-west...")
        "west":
            add_text("Sensing west...")
        "north-west":
            add_text("Sensing north-west...")
        _:
            add_text("[color=red]Unknown direction: %s[/color]" % direction)
            add_text("Usage: sense <direction>")
            add_text("Available directions:")
            add_text(" - north")
            add_text(" - north-east")
            add_text(" - east")
            add_text(" - south-east")
            add_text(" - south")
            add_text(" - south-west")
            add_text(" - west")
            add_text(" - north-west")
    emit_signal("sense_direction_changed", direction)

func help():
    add_text("Available commands:")
    add_text(" - clear: Clear the terminal")
    add_text(" - help: Show this help message")
    add_text(" - neofetch: Show system information")
    add_text(" - query <text>: ")

# --------------
# Text Rendering
# --------------

func add_text(text: String):
    history.append(text)
    render_text(text)

func add_entry(prompt: String):
    # copy entry
    var new_entry = Entry.instantiate()
    root.add_child(new_entry)
    new_entry.add_prompt(prompt)
    new_entry.connect("text_entered", Callable(self, "_on_entry_submitted"))

func _on_entry_submitted(response: String):
    history.append("> " + response)
    process_command(response)
    rerender_history()
    add_entry("Operator@Rover1 ~ % ")

func render_text(text: String, parent: Control = root):
    var rtlabel: RichTextLabel = RichTextLabel.new()
    rtlabel.bbcode_enabled = true
    rtlabel.append_text(text)
    rtlabel.autowrap_mode = TextServer.AUTOWRAP_WORD
    rtlabel.fit_content = true
    rtlabel.scroll_active = false
    parent.add_child(rtlabel)

func rerender_history():
    for child in root.get_children():
        root.remove_child(child)
        child.queue_free()
    # print tree
    for entry in history:
        render_text(entry)
    # Scroll to bottom if possible
    await get_tree().process_frame
    var scroll_container = get_node("ScrollContainer")
    scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
