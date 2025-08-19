extends Control

@onready var root: VBoxContainer = get_node("VBoxContainer")
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
        _:
            if command.begins_with("query "):
                query(command.replace("query ", "").strip_edges())
            else:
                add_text("[color=red]Unknown command: %s[/color]" % command)

func neofetch():
    # fake neofetch !
    var text = ""
    var file = FileAccess.open("res://terminal/neofetch.bbcode", FileAccess.READ)
    if file:
        text = file.get_as_text()
        file.close()
    else:
        text = "[color=red]Failed to load `neofetch.bbcode`. Please contact support.[/color]"
    add_text(text)

func query(_query_params: String):
    pass

func help():
    add_text("Available commands:")
    add_text(" - clear: Clear the terminal")
    add_text(" - help: Show this help message")
    add_text(" - neofetch: Show system information")
    add_text(" - query <text>: Query the system")

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
    if root.get_child_count() > 0:
        var last_child = root.get_child(root.get_child_count() - 1)
        if last_child is RichTextLabel:
            last_child.scroll_to_line(last_child.get_line_count() - 1)
