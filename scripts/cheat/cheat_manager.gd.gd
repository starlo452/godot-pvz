extends Node

var is_creative_mode: bool = false
var infinite_sun: bool = false
var zero_cooldown: bool = false
var plants_invincible: bool = false
var stop_spawning: bool = false
var continuous_planting: bool = false

var is_hypno_zombie: bool = false 
var is_time_stopped: bool = false 
var is_door_locked: bool = false 
var zombie_cache: Array = []
var plant_cache: Array = []

var cached_slot_battle = null

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _process(_delta: float) -> void:
	if not is_creative_mode: return
	
	# 锁定阳光
	if not is_instance_valid(cached_slot_battle):
		var curr_scene = get_tree().current_scene
		if curr_scene:
			var cm = curr_scene.find_child("CardManager", true, false)
			if cm and "card_slot_battle" in cm:
				cached_slot_battle = cm.card_slot_battle
	if is_instance_valid(cached_slot_battle):
		if cached_slot_battle.sun_value < 9999:
			cached_slot_battle.sun_value = 9999
			
	# 魅惑僵尸左边界空气墙
	if is_hypno_zombie:
		var all_zombies = get_tree().root.find_children("*", "Node2D", true, false).filter(func(n): return "is_hypno" in n and n.is_hypno and n.has_method("character_death"))
		for z in all_zombies:
			if is_instance_valid(z) and z.global_position.x < 50:
				z.global_position.x = 50
				if "direction_x_root" in z: z.direction_x_root = -1

	# 把门焊死
	if is_door_locked:
		var threats = get_tree().root.find_children("*", "Node2D", true, false).filter(func(n): return n.has_method("character_death") and "is_death" in n and not n.is_death)
		for z in threats:
			# 【核心修复】如果是魅惑僵尸，绝对不杀，放它一马！
			var is_hypno = false
			if "is_hypno" in z:
				is_hypno = z.is_hypno
				
			if not is_hypno and z.global_position.x < 30:
				z.character_death_disappear()

func _on_node_added(node: Node) -> void:
	if not is_creative_mode: return
	if node.has_method("character_death") and node.has_method("be_hypno"):
		if is_hypno_zombie:
			# 【核心修复】把定时器绑定在僵尸自己身上。如果僵尸瞬间死了，定时器直接取消，不会再报 Lambda capture 错误
			var t = Timer.new()
			t.wait_time = 0.2
			t.one_shot = true
			t.timeout.connect(func():
				if is_instance_valid(node) and not node.is_queued_for_deletion():
					node.be_hypno()
					node.global_position.x = 200
					_force_visible(node)
				t.queue_free()
			)
			node.add_child(t)
			t.start()
			
		if is_time_stopped:
			_freeze_zombie(node, true)

func _force_visible(node: Node) -> void:
	if node is Sprite2D or node is AnimatedSprite2D:
		node.visible = true
		node.modulate = Color(1.0, 0.5, 1.0)
	elif "visible" in node:
		node.visible = true
	for child in node.get_children():
		_force_visible(child)

func enable_creative_mode():
	is_creative_mode = true
	infinite_sun = true
	zero_cooldown = true
	continuous_planting = true

func toggle_invincible():
	plants_invincible = not plants_invincible

func toggle_stop_spawning():
	stop_spawning = not stop_spawning

func toggle_door_lock():
	is_door_locked = not is_door_locked

func clear_zombies():
	var zombies = get_tree().root.find_children("*", "Zombie000Base", true, false)
	for z in zombies:
		if is_instance_valid(z): z.queue_free()

func toggle_time_stop():
	is_time_stopped = not is_time_stopped
	var targets = get_tree().root.find_children("*", "Zombie000Base", true, false)
	var bosses = get_tree().root.find_children("*", "Node2D", true, false).filter(func(n): return "boss" in n.name.to_lower() and n.has_method("character_death"))
	targets.append_array(bosses)
	for z in targets:
		if is_instance_valid(z):
			_freeze_zombie(z, is_time_stopped)

func _freeze_zombie(z: Node, freeze: bool) -> void:
	z.set_process(not freeze)
	z.set_physics_process(not freeze)
	for child in z.get_children():
		if child is AnimationPlayer or child is AnimationTree or "StateMachine" in child.name or "Anim" in child.name or "Attack" in child.name:
			child.set_process(not freeze)
			child.set_physics_process(not freeze)

func add_lawn_mowers():
	var curr_scene = get_tree().current_scene
	if curr_scene and curr_scene.has_node("Manager/GameItemManager/GIM_LawnMover"):
		var mgr = curr_scene.get_node("Manager/GameItemManager/GIM_LawnMover")
		if mgr.has_method("create_all_lawn_movers"): mgr.call("create_all_lawn_movers")

func trigger_lawn_mowers():
	var mowers = get_tree().root.find_children("*", "LawnMower", true, false)
	if mowers.is_empty():
		mowers = get_tree().root.find_children("*", "Node2D", true, false).filter(func(n): return n.name.to_lower().contains("mower"))
	for m in mowers:
		if is_instance_valid(m):
			if m.has_method("move"): m.call("move")
			elif m.has_method("start"): m.call("start")
			elif m.has_method("run"): m.call("run")
			elif "curr_state" in m: m.curr_state = 1
			else:
				var tween = create_tween()
				tween.tween_property(m, "global_position:x", m.global_position.x + 1500, 1.5)

func change_scene(scene_name: String):
	zombie_cache.clear()
	plant_cache.clear()
	cached_slot_battle = null 
	
	var zombies = get_tree().root.find_children("*", "Zombie000Base", true, false)
	for z in zombies:
		if is_instance_valid(z) and not z.is_queued_for_deletion():
			zombie_cache.append({"type": int(z.zombie_type), "x": z.global_position.x, "lane": z.lane})
			
	var pcm = get_tree().root.find_child("PlantCellManager", true, false)
	if pcm and "all_plant_cells" in pcm:
		for col in pcm.all_plant_cells:
			for cell in col:
				if is_instance_valid(cell) and "plant_in_cell" in cell:
					for place in cell.plant_in_cell:
						var p = cell.plant_in_cell[place]
						if is_instance_valid(p):
							plant_cache.append({"type": int(p.plant_type), "pos": cell.row_col})

	var scene_path = ""
	var level_data_path = ""
	
	if scene_name.to_lower() == "front":
		scene_path = Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameFront]
		level_data_path = "res://resources/level_date_resource/mode_adventure/adventure_1_01.tres"
	elif scene_name.to_lower() == "pool":
		scene_path = Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameBack]
		level_data_path = "res://resources/level_date_resource/mode_adventure/adventure_3_01.tres"
	elif scene_name.to_lower() == "roof":
		scene_path = Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameRoof]
		level_data_path = "res://resources/level_date_resource/mode_adventure/adventure_5_01.tres"
	else: return
		
	if ResourceLoader.exists(level_data_path):
		Global.game_para = load(level_data_path)
		Global.game_para.game_mode = MainSceneRegistry.MainScenes.ChooseLevelAdventure
		if infinite_sun: Global.game_para.start_sun = 9999
		
	if scene_path != "":
		get_tree().change_scene_to_file.call_deferred(scene_path)
		get_tree().create_timer(0.5).timeout.connect(_restore_entities)

func _restore_entities():
	var curr_scene = get_tree().current_scene
	if not curr_scene: return
	var is_night_map = Global.game_para.game_BG in [1, 3]
	var pcm = curr_scene.find_child("PlantCellManager", true, false)
	if pcm and "all_plant_cells" in pcm:
		for p_data in plant_cache:
			var p_type = p_data["type"]
			var pos = p_data["pos"]
			if pos.x >= pcm.all_plant_cells.size() or pos.y >= pcm.all_plant_cells[pos.x].size(): continue
			var cell = pcm.all_plant_cells[pos.x][pos.y]
			if is_instance_valid(cell):
				var new_plant = cell.create_plant(p_type, false, true, false, false)
				if is_night_map and is_instance_valid(new_plant) and new_plant.has_method("coffee_bean_awake_up"):
					new_plant.call("coffee_bean_awake_up")
	
	var zm = curr_scene.find_child("ZombieManager", true, false)
	if not zm or "all_zombie_rows" not in zm: return
	var max_lanes = zm.all_zombie_rows.size()
	for data in zombie_cache:
		var z_type = data["type"]
		var x = data["x"]
		var lane = data["lane"]
		if lane >= max_lanes: lane = max_lanes - 1 
		var pos = Vector2(x, zm.all_zombie_rows[lane].zombie_create_position.global_position.y)
		var para = {
			Zombie000Base.E_ZInitAttr.CharacterInitType: Character000Base.E_CharacterInitType.IsNorm,
			Zombie000Base.E_ZInitAttr.Lane: lane,
			Zombie000Base.E_ZInitAttr.CurrWave: 1
		}
		var new_z = zm.create_norm_zombie(z_type, zm.all_zombie_rows[lane], para, pos)
		if is_hypno_zombie and is_instance_valid(new_z):
			new_z.be_hypno()
			new_z.global_position.x = 200
			_force_visible(new_z)
		if Global.game_para.game_BG in [2, 3] and lane in [2, 3]:
			if "swim_box_component" in new_z and new_z.swim_box_component:
				new_z.swim_box_component.set_process(true)
