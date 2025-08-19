extends HBoxContainer

signal text_entered(prompt: String, response: String)
@onready var prompt_label: RichTextLabel = get_first_rich_text_label()
@onready var line_edit: LineEdit = get_node_or_null("LineEdit")

func get_first_rich_text_label():
    for child in get_children():
        if child is RichTextLabel:
            return child
    return null

func add_prompt(prompt: String):
    print(prompt_label)
    print_tree()
    prompt_label.append_text(prompt)
    prompt_label.custom_minimum_size = Vector2(prompt_label.get_content_width(), prompt_label.get_content_height())

func _gui_input(event):
    if event is InputEventMouseButton and event.pressed:
        if line_edit:
            line_edit.grab_focus()

func _on_text_submitted(new_text: String) -> void:
    var prompt = prompt_label.get_text()
    emit_signal("text_entered", prompt, new_text)
