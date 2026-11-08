extends CanvasLayer

@onready var panel: Panel = get_node_or_null("Panel")
@onready var output_label: RichTextLabel = get_node_or_null("Panel/RichTextLabel")
@onready var input_line: LineEdit = get_node_or_null("Panel/LineEdit")

var ui_panel: PanelContainer
var left_panel: PanelContainer
var card_popup: Control
var popup_grid: GridContainer
var hypno_btn: Button

func _ready():
	if panel == null: return
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -300
	var style = StyleBoxFlat.new(); style.bg_color = Color(0,0,0,0.85)
	panel.add_theme_stylebox_override("panel", style)
	
	input_line.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	input_line.offset_top = -45; input_line.offset_left = 10; input_line.offset_right = -10
	input_line.text_submitted.connect(_on_command_entered)
	panel.visible = false
	
	_create_side_buttons()
	_create_left_buttons()
	_create_popup()

func _create_side_buttons():
	ui_panel = PanelContainer.new()
	ui_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	ui_panel.offset_left = -160; ui_panel.offset_right = -20
	ui_panel.offset_top = -180; ui_panel.offset_bottom = 180 
	ui_panel.visible = false 
	
	var vbox = VBoxContainer.new(); ui_panel.add_child(vbox)
	
	var b1 = Button.new(); b1.text = "植物无敌 [关]"
	b1.pressed.connect(func(): CheatManager.toggle_invincible(); b1.text = "植物无敌 [开]" if CheatManager.plants_invincible else "植物无敌 [关]")
	vbox.add_child(b1)

	var b2 = Button.new(); b2.text = "停止出怪 [关]"
	b2.pressed.connect(func(): CheatManager.toggle_stop_spawning(); b2.text = "停止出怪 [开]" if CheatManager.stop_spawning else "停止出怪 [关]")
	vbox.add_child(b2)
	
	var b3 = Button.new(); b3.text = "时停 [关]"
	b3.pressed.connect(func(): CheatManager.toggle_time_stop(); b3.text = "时停 [开]" if CheatManager.is_time_stopped else "时停 [关]")
	vbox.add_child(b3)
	
	var b4 = Button.new(); b4.text = "一键清场"
	b4.pressed.connect(func(): CheatManager.clear_zombies())
	vbox.add_child(b4)

	var b5 = Button.new(); b5.text = "把门焊死 [关]"
	b5.pressed.connect(func(): 
		CheatManager.toggle_door_lock()
		b5.text = "把门焊死 [开]" if CheatManager.is_door_locked else "把门焊死 [关]"
	)
	vbox.add_child(b5)
	
	add_child(ui_panel)

func _create_left_buttons():
	left_panel = PanelContainer.new()
	left_panel.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	left_panel.offset_left = 20; left_panel.offset_right = 160
	left_panel.offset_top = -80; left_panel.offset_bottom = 80
	left_panel.visible = false 
	
	var vbox = VBoxContainer.new(); left_panel.add_child(vbox)
	
	var card_btn = Button.new(); card_btn.text = "全部卡牌"
	card_btn.pressed.connect(func(): 
		populate_all_cards()
		card_popup.visible = true
	)
	vbox.add_child(card_btn)
	
	var add_car_btn = Button.new(); add_car_btn.text = "左键补车"
	add_car_btn.pressed.connect(func(): CheatManager.add_lawn_mowers())
	vbox.add_child(add_car_btn)
	
	var run_car_btn = Button.new(); run_car_btn.text = "右键放车"
	run_car_btn.pressed.connect(func(): CheatManager.trigger_lawn_mowers())
	vbox.add_child(run_car_btn)
	
	add_child(left_panel)

func _create_popup():
	card_popup = Panel.new()
	card_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_popup.visible = false
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0,0,0,0.8)
	card_popup.add_child(bg)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 50; scroll.offset_top = 50; scroll.offset_right = -50; scroll.offset_bottom = -100
	card_popup.add_child(scroll)
	
	popup_grid = GridContainer.new()
	popup_grid.columns = 8
	popup_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(popup_grid)
	
	hypno_btn = Button.new()
	hypno_btn.text = "魅惑僵尸 [关]"
	hypno_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hypno_btn.offset_top = -60; hypno_btn.offset_bottom = -10
	hypno_btn.offset_left = -200; hypno_btn.offset_right = -100
	hypno_btn.pressed.connect(func(): 
		CheatManager.is_hypno_zombie = not CheatManager.is_hypno_zombie
		hypno_btn.text = "魅惑僵尸 [开]" if CheatManager.is_hypno_zombie else "魅惑僵尸 [关]"
	)
	card_popup.add_child(hypno_btn)
	
	var close_btn = Button.new()
	close_btn.text = "关闭 (不取消手持)"
	close_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	close_btn.offset_left = 50; close_btn.offset_right = 250; close_btn.offset_top = -60; close_btn.offset_bottom = -10
	close_btn.pressed.connect(func(): 
		card_popup.visible = false
		get_viewport().set_input_as_handled()
	)
	card_popup.add_child(close_btn)
	
	add_child(card_popup)

func populate_all_cards():
	for child in popup_grid.get_children(): child.queue_free()
	
	# 【核心修改】只加载植物和普通僵尸，彻底移除僵王
	var all_refs = AllCards.get_references(ResourceCardReference.CardType.Plant)
	var all_zombies = AllCards.get_references(ResourceCardReference.CardType.Zombie)
	var all_cards = all_refs + all_zombies
	
	for ref in all_cards:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 100)
		
		var card_name = "未知"
		if "card_name" in ref:
			card_name = ref.card_name
		elif "content_id" in ref:
			card_name = str(ref.content_id)
			
		btn.text = card_name
		
		btn.pressed.connect(func(): 
			var new_card = AllCards.create_card(ref, Card.CardContext.Battle)
			if new_card != null:
				var curr_scene = get_tree().current_scene
				if curr_scene:
					curr_scene.add_child(new_card)
					new_card.visible = false
					new_card.position = Vector2(-1000, -1000)
					
				EventBus.push_event("main_game_click_card", [new_card])
				
			card_popup.visible = false
			get_viewport().set_input_as_handled()
		)
		popup_grid.add_child(btn)

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			panel.visible = not panel.visible
			if panel.visible:
				input_line.grab_focus()
			get_viewport().set_input_as_handled()

func _on_command_entered(text: String):
	var cmd = text.strip_edges()
	input_line.clear()
	if cmd == "": return
	output_label.text += "\n> " + cmd
	
	if cmd == "wwssadadBABA":
		CheatManager.enable_creative_mode()
		output_label.text += "\n【终端】创造模式开启！"
		ui_panel.visible = true
		left_panel.visible = true
		return
		
	match cmd.to_lower():
		"clear": CheatManager.clear_zombies()
		"front": CheatManager.change_scene("front")
		"pool": CheatManager.change_scene("pool")
		"roof": CheatManager.change_scene("roof")
		_: output_label.text += "\n【终端】未知指令。"
