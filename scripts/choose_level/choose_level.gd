extends Control
class_name ChooseLevel

var next_level_number: int = 1
@onready var all_page: Control = $AllPage
@onready var label_page: Label = get_node_or_null("LabelPage")

@export var game_mode: MainSceneRegistry.MainScenes = MainSceneRegistry.MainScenes.Null
var open_level_num: int = -1
var all_pages_array: Array[GridContainer] = []
@export var curr_page := 0

var bgm_choose_card: AudioStream = preload("res://assets/audio/BGM/choose_card.mp3")

const BIG_NAMES := ["白天", "黑夜", "泳池", "迷雾", "屋顶"]
const BIG_COVERS := {
	"白天": "res://assets/image/Almanac/Almanac_GroundDay.jpg",
	"黑夜": "res://assets/image/Almanac/Almanac_GroundNight.jpg",
	"泳池": "res://assets/image/Almanac/Almanac_GroundPool.jpg",
	"迷雾": "res://assets/image/Almanac/Almanac_GroundNightPool.jpg",
	"屋顶": "res://assets/image/Almanac/Almanac_GroundRoof.jpg",
}

func _ready() -> void:
	if game_mode == MainSceneRegistry.MainScenes.ChooseLevelAdventure:
		_regenerate_adventure_buttons()

	if not Global.config_service.open_all_level:
		if game_mode == MainSceneRegistry.MainScenes.ChooseLevelAdventure:
			open_level_num = 1
		elif game_mode == MainSceneRegistry.MainScenes.ChooseLevelCustom:
			open_level_num = -1
		else:
			open_level_num = 3
	else:
		open_level_num = -1

	for page_i in all_page.get_child_count():
		var page = all_page.get_child(page_i)
		if not (page is GridContainer):
			continue
		all_pages_array.append(page)
		page.visible = false
		for node in page.get_children():
			if node is ChooseLevelButton:
				var level_id: String = generate_level_id()
				if node.curr_level_data_game_para == null:
					continue
				node.signal_choose_level_button.connect(_on_choose_level_button)
				node.curr_level_data_game_para.set_choose_level(game_mode, page_i, level_id)
				var curr_level_state_data: Dictionary = Global.global_game_state.curr_all_level_state_data.get(node.curr_level_data_game_para.save_game_name, {})
				node.update_curr_level_button_state(curr_level_state_data)
				update_lock_level(node, curr_level_state_data)

	print("当前模式关卡数量:", next_level_number - 1)
	_ready_update_page()

	if game_mode == MainSceneRegistry.MainScenes.ChooseLevelAdventure:
		_create_page_buttons()

func _create_page_buttons() -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "PageButtons"
	hbox.anchor_left = 0.5
	hbox.anchor_right = 0.5
	hbox.anchor_top = 1.0
	hbox.anchor_bottom = 1.0
	hbox.offset_left = -160
	hbox.offset_right = 160
	hbox.offset_top = -70
	hbox.offset_bottom = -10
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 30)

	var prev_btn := Button.new()
	prev_btn.text = "上一页"
	prev_btn.custom_minimum_size = Vector2(120, 50)
	prev_btn.pressed.connect(_on_last_pressed)
	hbox.add_child(prev_btn)

	var next_btn := Button.new()
	next_btn.text = "下一页"
	next_btn.custom_minimum_size = Vector2(120, 50)
	next_btn.pressed.connect(_on_next_pressed)
	hbox.add_child(next_btn)

	add_child(hbox)

func _regenerate_adventure_buttons() -> void:
	var template_grid: GridContainer = null
	for child in all_page.get_children():
		if child is GridContainer:
			template_grid = child
			break
	if template_grid == null: return

	var t_anchor_l = template_grid.anchor_left
	var t_anchor_t = template_grid.anchor_top
	var t_anchor_r = template_grid.anchor_right
	var t_anchor_b = template_grid.anchor_bottom
	var t_off_l = template_grid.offset_left
	var t_off_t = template_grid.offset_top
	var t_off_r = template_grid.offset_right
	var t_off_b = template_grid.offset_bottom
	var t_pos = template_grid.position
	var t_size = template_grid.size
	var t_grow_h = template_grid.grow_horizontal
	var t_grow_v = template_grid.grow_vertical
	var h_sep = template_grid.get_theme_constant("h_separation")
	var v_sep = template_grid.get_theme_constant("v_separation")

	for child in template_grid.get_children():
		template_grid.remove_child(child)
		child.queue_free()
	template_grid.columns = 5

	var grids: Array[GridContainer] = [template_grid]
	for i in range(1, 5):
		var grid := GridContainer.new()
		grid.anchor_left = t_anchor_l
		grid.anchor_top = t_anchor_t
		grid.anchor_right = t_anchor_r
		grid.anchor_bottom = t_anchor_b
		grid.offset_left = t_off_l
		grid.offset_top = t_off_t
		grid.offset_right = t_off_r
		grid.offset_bottom = t_off_b
		grid.columns = 5
		grid.grow_horizontal = t_grow_h
		grid.grow_vertical = t_grow_v
		grid.add_theme_constant_override("h_separation", h_sep)
		grid.add_theme_constant_override("v_separation", v_sep)
		all_page.add_child(grid)
		grid.position = t_pos
		grid.size = t_size
		grids.append(grid)

	var button_scene: PackedScene = load("res://scenes/choose_level/choose_level_button.tscn")
	if button_scene == null: return

	var covers: Dictionary = {}
	for k in BIG_COVERS:
		var p: String = BIG_COVERS[k]
		if ResourceLoader.exists(p):
			covers[k] = load(p)

	var generated: int = 0
	for big in range(1, 6):
		var grid = grids[big - 1]
		var big_name: String = BIG_NAMES[big - 1]
		for small in range(1, 11):
			var file_name: String = "adventure_%d_%02d.tres" % [big, small]
			var path: String = "res://resources/level_date_resource/mode_adventure/" + file_name
			if not ResourceLoader.exists(path):
				continue
			var level_data: ResourceLevelData = load(path) as ResourceLevelData
			if level_data == null: continue
			var btn = button_scene.instantiate()
			btn.curr_level_data_game_para = level_data
			grid.add_child(btn)
			
			# 设置名字
			var label = btn.get_node_or_null("TextureButton/Label")
			if label != null:
				label.text = "%s-%d" % [big_name, small]
				
			# 【封面恢复】强行创建一个背景铺满按钮
			if covers.has(big_name):
				var bg = TextureRect.new()
				bg.texture = covers[big_name]
				bg.set_anchors_preset(Control.PRESET_FULL_RECT)
				bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
				bg.show_behind_parent = true
				
				var panel = btn.get_node_or_null("Panel")
				if panel != null:
					panel.add_child(bg)
				else:
					btn.add_child(bg)
					
			generated += 1

func update_lock_level(choose_level_button, curr_level_state_data: Dictionary):
	if open_level_num == -1: return
	if choose_level_button.curr_level_data_game_para.game_round == -1: return
	if curr_level_state_data.get("IsSuccess", false): return
	if open_level_num > 0:
		open_level_num -= 1
		return
	else:
		choose_level_button.lock_choose_level_button()

func _ready_update_page():
	if Global.game_para != null and Global.game_para.game_mode == game_mode:
		curr_page = Global.game_para.level_page
	if all_pages_array.is_empty(): return
	if curr_page >= all_pages_array.size():
		curr_page = 0
	all_pages_array[curr_page].visible = true
	if is_instance_valid(label_page):
		_update_page(curr_page)
	SoundManager.play_bgm(bgm_choose_card)

func generate_level_id() -> String:
	var id_str = "%04d" % next_level_number
	next_level_number += 1
	return id_str

func _on_choose_level_button(choose_level_button):
	Global.game_para = choose_level_button.curr_level_data_game_para
	choose_level_start_game(choose_level_button.curr_level_data_game_para.game_sences)

func choose_level_start_game(game_scense: MainSceneRegistry.MainScenes):
	get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[game_scense])

func back_start_menu():
	get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.StartMenu])

func _on_last_pressed() -> void:
	_update_page(curr_page - 1)

func _on_next_pressed() -> void:
	_update_page(curr_page + 1)

func _update_page(new_page: int):
	if all_pages_array.is_empty(): return
	new_page = posmod(new_page, all_pages_array.size())
	all_pages_array[curr_page].visible = false
	curr_page = new_page
	all_pages_array[curr_page].visible = true
	if is_instance_valid(label_page):
		label_page.text = "当前页数:" + str(curr_page + 1) + "/" + str(all_pages_array.size())
