extends VBoxContainer

var history: Array
enum MessageType { COMMAND, RESULT, INPUT }
var font = preload("res://fonts/VT323/VT323-Regular.ttf")


func _ready() -> void:
    history = []
    add_history(MessageType.RESULT, "Welcome to the terminal!")
    add_history(MessageType.RESULT, "Type 'help' for a list of commands.")
    add_history(MessageType.INPUT, "admin@rover1:~$ ")
    rerender_history()

func add_history(message: MessageType, contents: String) -> void:
    history.append({"type": message, "content": contents})

func rerender_history() -> void:
    if get_child_count() > 0:
        for child in get_children():
            remove_child(child)
            child.queue_free()

    for entry in history:
        var new_child: Control
        if entry.type == MessageType.INPUT:
            new_child = LineEdit.new()
            new_child.text = entry.content
            new_child.editable = true
        else:
            new_child = Label.new()
            new_child.text = entry.content
        
        new_child.size_flags_vertical = Control.SIZE_EXPAND
        new_child.add_theme_font_override("font", font)
        new_child.custom_minimum_size = Vector2(0, 64)
        new_child.add_theme_font_size_override("font_size", 64)
        var stylebox := StyleBoxFlat.new()
        stylebox.bg_color = Color(0,0,0,0)
        stylebox.content_margin_bottom = 20
        stylebox.content_margin_top = 20
        stylebox.content_margin_left = 20
        new_child.add_theme_stylebox_override("normal", stylebox)
        add_child(new_child)

func _update_input_messages(line_edit: LineEdit, new_text: String) -> void:
    for i in range(history.size()):
        if history[i].type == MessageType.INPUT && history[i].content == line_edit.text:
            # replace element with a Label
            history[i].type = MessageType.RESULT
            history[i].content = new_text
            break
    rerender_history()
