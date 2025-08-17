extends CodeEdit

# Terminal state
var prompt := "$ "
var history := []
var valid_commands := ["help", "query", "neofetch"]


func _ready():
    clear()
    _print_prompt()
    set_process_input(true)


func _print_prompt():
    var color = Color(0.6, 1, 0.6)
    var prompt_text = "[color=%s]%s[/color]" % [color.to_html(), prompt]
    insert_text_at_caret(prompt_text)


func _unhandled_key_input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ENTER:
            var line = get_line(get_caret_line())
            var cmd = line.replace(prompt, "").strip_edges()
            history.append(cmd)
            _handle_command(cmd)
            _print_prompt()


func _handle_command(cmd: String):
    var args = cmd.split(" ")
    var main = args[0]
    if main == "help":
        _print_help()
    elif main == "query" and args.size() > 1:
        _print_query(args[1])
    elif main == "neofetch":
        _print_neofetch()
    else:
        _print_error("Unknown command: %s" % cmd)


func _print_help():
    var color = Color(0.5, 0.8, 1)
    var output = "[color=%s]Valid commands:\n  help\n  query <dir>\n  neofetch[/color]\n" % color.to_html()
    insert_text_at_caret(output)


func _print_query(dir: String):
    var color = Color(1, 0.9, 0.5)
    var output = "[color=%s]Querying directory: %s\nFake contents: file1.txt, file2.png, folder/[/color]\n" % [color.to_html(), dir]
    insert_text_at_caret(output)


func _print_neofetch():
    var color = Color(0.8, 1, 0.7)
    var output = "[color=%s]OS: GodotOS\nKernel: 4.0.0\nShell: FakeTerminal\nResolution: 800x600\n[/color]\n" % color.to_html()
    insert_text_at_caret(output)


func _print_error(msg: String):
    var color = Color(1, 0.4, 0.4)
    var output = "[color=%s]%s[/color]\n" % [color.to_html(), msg]
    insert_text_at_caret(output)
