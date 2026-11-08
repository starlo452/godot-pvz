extends CanvasLayer

@onready var panel: Panel = get_node_or_null("Panel")
@onready var output_label: RichTextLabel = get_node_or_null("Panel/RichTextLabel")
@onready var input_line: LineEdit = get_node_or_null("Panel/LineEdit")

var ui_panel: PanelContainer
var btn_invincible: Button
var btn_stop_spawn: Button

func _ready():
	if panel == null or input_line == null: return

	# 初始化终端面板 UI（底部）
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -300 
	panel.offset_bottom = 0
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	panel.add_theme_stylebox_override("panel", style)
	
	output_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	output_label.offset_left = 10
	output_label.offset_top = 10
	output_label.offset_right = -10
	output_label.offset_bottom = -50
	output_label.scroll_following = true
	
	input_line.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	input_line.offset_left = 10
	input_line.offset_top = -45
	input_line.offset_right = -10
	input_line.offset_bottom = -5
	var line_style = StyleBoxFlat.new()
	line_style.bg_color = Color(0.1, 0.1, 0.1, 1)
	input_line.add_theme_stylebox_override("normal", line_style)
	input_line.add_theme_stylebox_override("focus", line_style)
	input_line.add_theme_color_override("font_color", Color(0, 1, 0, 1))

	panel.visible = false
	input_line.text_submitted.connect(_on_command_entered)
	output_label.text = "=== 欢迎使用开发者终端 ===\n输入 help 查看所有指令"

	_create_side_buttons()

func _create_side_buttons():
	ui_panel = PanelContainer.new()
	# 【修改点】：将按钮面板移至屏幕正右侧居中，避开主菜单和终端
	ui_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	ui_panel.offset_left = -160
	ui_panel.offset_top = -80
	ui_panel.offset_right = -20
	ui_panel.offset_bottom = 80
	ui_panel.visible = false 
	
	var vbox = VBoxContainer.new()
	ui_panel.add_child(vbox)
	
	btn_invincible = Button.new()
	btn_invincible.text = "植物无敌 [关]"
	btn_invincible.pressed.connect(func(): 
		CheatManager.plants_invincible = not CheatManager.plants_invincible
		btn_invincible.text = "植物无敌 [开]" if CheatManager.plants_invincible else "植物无敌 [关]"
	)
	vbox.add_child(btn_invincible)

	btn_stop_spawn = Button.new()
	btn_stop_spawn.text = "停止出怪 [关]"
	btn_stop_spawn.pressed.connect(func():
		CheatManager.stop_spawning = not CheatManager.stop_spawning
		btn_stop_spawn.text = "停止出怪 [开]" if CheatManager.stop_spawning else "停止出怪 [关]"
	)
	vbox.add_child(btn_stop_spawn)

	add_child(ui_panel)

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			if panel == null: return
			panel.visible = not panel.visible
			if panel.visible:
				input_line.grab_focus()
			get_viewport().set_input_as_handled()

func _on_command_entered(text: String):
	var cmd = text.strip_edges()
	input_line.clear()
	if cmd == "": return
	output_label.text += "\n> " + cmd
	
	if cmd == "help":
		output_label.text += "\n=== 可用指令 ===\n"
		output_label.text += "wwssadadBABA : 激活创造模式(解锁按钮)\n"
		output_label.text += "clear : 清除全屏僵尸\n"
		output_label.text += "front / pool / roof : 切换场景"
		return
		
	if cmd == "wwssadadBABA":
		CheatManager.enable_creative_mode()
		output_label.text += "\n【终端】秘籍激活成功！创造模式已开启。"
		ui_panel.visible = true 
		return
	
	match cmd.to_lower():
		"clear": CheatManager.clear_zombies()
		"front": CheatManager.change_scene("front")
		"pool": CheatManager.change_scene("pool")
		"roof": CheatManager.change_scene("roof")
		_: output_label.text += "\n【终端】未知指令。"
