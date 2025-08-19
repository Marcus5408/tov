extends Control

@onready var root: VBoxContainer = get_node("VBoxContainer")
var Entry = load("res://terminal/Entry.tscn")
var history: Array = []

func _ready():
    add_text("Last login: Tue Aug 19 1:11:58 on ttys000")
    rerender_history()
    add_entry("Operator@Rover1 ~ % ")

func _process(_delta: float) -> void:
    pass

func neofetch():
    # fake neofetch
    var text = load("res://terminal/neofetch.bbcode")
    add_text(text)

func query():
    pass

func add_text(text: String):
    history.append(text)

func add_entry(prompt: String):
    # copy entry
    var new_entry = Entry.instantiate()
    root.add_child(new_entry)
    print_tree_pretty()
    new_entry.add_prompt(prompt)

func _on_entry_submitted(entry: LineEdit, prompt: String):
    history.append(prompt + entry.text)
    entry.editable = false
    rerender_history()
    add_entry("$ ")

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
