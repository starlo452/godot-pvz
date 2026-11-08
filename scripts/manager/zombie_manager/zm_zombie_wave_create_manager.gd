extends Node
## 僵尸波次生成管理器
class_name ZombieWaveCreateManager

#region 波次生成僵尸管理器参数
var zombie_multy := 1
var range_num_bungi:Vector2i = Vector2i(3,5)
#endregion
@onready var zombie_manager: ZombieManager = %ZombieManager
@onready var zombie_choose_row_system: ZombieChooseRowSystem = %ZombieChooseRowSystem

var zombie_weights: Dictionary[CharacterRegistry.ZombieType, int] = CharacterRegistry.ZombieSpawnWeights.duplicate()
var zombie_choose_random_pool:RandomPicker
@export var max_zombies_per_wave = 50
var min_power:=100
var wave_all_zombies:Array[Zombie000Base]

func init_zombie_wave_create_manager(game_para:ResourceLevelData):
	zombie_multy = game_para.zombie_multy
	range_num_bungi = game_para.range_num_bungi
	zombie_choose_row_system.init_zombie_choose_row_system(zombie_manager.all_zombie_rows)
	update_zombie_refresh_types()

func update_zombie_refresh_types():
	var zombie_choose_random_pool_data:Array[Array] = []
	min_power = 100
	for zombie_type in zombie_manager.zombie_refresh_types:
		if min_power > CharacterRegistry.ZombieSpawnPower[zombie_type]:
			min_power = CharacterRegistry.ZombieSpawnPower[zombie_type]
		zombie_choose_random_pool_data.append([zombie_type, zombie_weights[zombie_type]])
	print("更新僵尸随机选择池")
	zombie_choose_random_pool = RandomPicker.new(zombie_choose_random_pool_data)

#region 创建当前波次僵尸
func create_curr_wave_all_zombies(wave:int, is_big_wave:bool):
	# ================= 作弊：停止出怪 =================
	if CheatManager.stop_spawning:
		wave_all_zombies.clear()
		return wave_all_zombies
	# ==================================================

	var wave_spawn :Array[CharacterRegistry.ZombieType] = create_curr_wave_zombie_list(wave, is_big_wave)
	var special_base_weight:Array[float] = []
	wave_all_zombies.clear()
	var curr_wave_zombie_date:Array[Dictionary]

	for i in range(wave_spawn.size()):
		var zombie_type : CharacterRegistry.ZombieType = wave_spawn[i]
		var lane :int = -1
		if zombie_type == CharacterRegistry.ZombieType.Z014Bobsled:
			if special_base_weight.is_empty():
				for row_ice_road:Array[IceRoad] in zombie_manager.all_ice_roads:
					if row_ice_road.is_empty():
						special_base_weight.append(0)
					else:
						special_base_weight.append(1)
				print(special_base_weight)
			if GlobalUtils.sum_arr(special_base_weight) == 0:
				zombie_type = CharacterRegistry.ZombieType.Z013Zamboni
				lane = zombie_choose_row_system.select_spawn_row(Global.character_registry.ZombieInfo[zombie_type][CharacterRegistry.ZombieInfoAttribute.ZombieRowType])
			else:
				lane = zombie_choose_row_system.select_spawn_row(Global.character_registry.ZombieInfo[zombie_type][CharacterRegistry.ZombieInfoAttribute.ZombieRowType], special_base_weight)
		else:
			lane = zombie_choose_row_system.select_spawn_row(Global.character_registry.ZombieInfo[zombie_type][CharacterRegistry.ZombieInfoAttribute.ZombieRowType])
		if lane < 0:
			continue
		curr_wave_zombie_date.append(
			{
				"zombie_type":zombie_type,
				"lane":lane,
			}
		)
	for curr_wave_one_zombie_date in curr_wave_zombie_date:
		var zombie = wave_create_zombie(
			curr_wave_one_zombie_date["zombie_type"],
			curr_wave_one_zombie_date["lane"],
			wave
		)
		if is_instance_valid(zombie):
			wave_all_zombies.append(zombie)

	return wave_all_zombies

func wave_create_zombie(
	zombie_type:CharacterRegistry.ZombieType,
	lane:int,
	curr_wave:int,
	init_zombie_special:Callable = Callable()
):
	if lane < 0 or lane >= zombie_manager.all_zombie_rows.size():
		return null
	var zombie_init_para:Dictionary = {
		Zombie000Base.E_ZInitAttr.CharacterInitType:Character000Base.E_CharacterInitType.IsNorm,
		Zombie000Base.E_ZInitAttr.Lane:lane,
		Zombie000Base.E_ZInitAttr.CurrWave:curr_wave,
	}
	var zombie_parent = zombie_manager.all_zombie_rows[lane]
	var zombie_glo_pos = zombie_manager.all_zombie_rows[lane].zombie_create_position.global_position + Vector2(randf_range(-10, 10), 0)

	var zombie = zombie_manager.create_norm_zombie(zombie_type,zombie_parent,zombie_init_para, zombie_glo_pos, init_zombie_special)

	return zombie

func create_curr_wave_zombie_list(wave:int, is_big_wave:bool):
	var curr_wave_power_limit = calculate_wave_power_limit(wave, is_big_wave)
	_update_weights(wave)
	var wave_spawn :Array[CharacterRegistry.ZombieType] = get_curr_wave_zombie_list(wave, is_big_wave, curr_wave_power_limit)

	return wave_spawn

func calculate_wave_power_limit(wave:int, is_big_wave: bool) -> int:
	@warning_ignore("integer_division")
	var base_power_limit:int = wave / 3 + 1
	if is_big_wave:
		return int(base_power_limit * 2.5) * zombie_multy

	return base_power_limit * zombie_multy

func _update_weights(wave: int) -> void:
	zombie_weights = CharacterRegistry.ZombieSpawnWeights.duplicate()
	var decay_steps: int = clampi(wave - 5, 0, 20)
	zombie_weights[CharacterRegistry.ZombieType.Z001Norm] -= decay_steps * 180
	zombie_weights[CharacterRegistry.ZombieType.Z003Cone] -= decay_steps * 150
	for zombie_type: CharacterRegistry.ZombieType in [CharacterRegistry.ZombieType.Z001Norm, CharacterRegistry.ZombieType.Z003Cone]:
		if zombie_type in zombie_manager.zombie_refresh_types:
			zombie_choose_random_pool.update_item_weight(zombie_type, zombie_weights[zombie_type], false)
	zombie_choose_random_pool.rebuild_alias_table()

func get_curr_wave_zombie_list(wave:int, is_big_wave: bool, curr_wave_power_limit:int) ->Array[CharacterRegistry.ZombieType]:
	var wave_spawn :Array[CharacterRegistry.ZombieType]= []
	var total_power = 0
	var curr_spare_slot = max_zombies_per_wave

	if is_big_wave:
		wave_spawn.append(CharacterRegistry.ZombieType.Z002Flag)
		total_power += CharacterRegistry.ZombieSpawnPower[CharacterRegistry.ZombieType.Z002Flag]
		curr_spare_slot -= 1

		if wave == 9:
			for i in range(4):
				wave_spawn.append(CharacterRegistry.ZombieType.Z001Norm)
				total_power += CharacterRegistry.ZombieSpawnPower[CharacterRegistry.ZombieType.Z001Norm]
				curr_spare_slot -= 1
		else:
			for i in range(8):
				wave_spawn.append(CharacterRegistry.ZombieType.Z001Norm)
				total_power += CharacterRegistry.ZombieSpawnPower[CharacterRegistry.ZombieType.Z001Norm]
				curr_spare_slot -= 1

	while curr_spare_slot > 0 and total_power < curr_wave_power_limit:
		var selected_zombie:CharacterRegistry.ZombieType = zombie_choose_random_pool.get_random_item()
		var zombie_power_value: int = CharacterRegistry.ZombieSpawnPower[selected_zombie]

		if total_power + zombie_power_value <= curr_wave_power_limit:
			wave_spawn.append(selected_zombie)
			total_power += zombie_power_value
			curr_spare_slot -= 1
		elif curr_wave_power_limit - total_power < min_power:
			for i in range(curr_wave_power_limit - total_power):
				wave_spawn.append(CharacterRegistry.ZombieType.Z001Norm)
				total_power += CharacterRegistry.ZombieSpawnPower[CharacterRegistry.ZombieType.Z001Norm]
				curr_spare_slot -= 1
			continue
		else:
			continue

	return wave_spawn

#endregion

#region 大波僵尸时生成特殊僵尸
func spawn_special_zombie_in_big_wave(is_final:=false):
	# ================= 作弊：停止出怪 =================
	if CheatManager.stop_spawning:
		return
	# ==================================================

	if is_final:
		if not zombie_manager.is_ice:
			print("生成珊瑚僵尸")
			spawn_sea_weed_zombies()
		else:
			print("被冰冻无法生成珊瑚僵尸")
	if zombie_manager.is_bungi:
		spawn_bungi_zombies()

func spawn_sea_weed_zombies():
	var zombie_row_pool_i :Array[int]
	for i in range(zombie_manager.all_zombie_rows.size()):
		if zombie_manager.all_zombie_rows[i].zombie_row_type == CharacterRegistry.ZombieRowType.Pool:
			zombie_row_pool_i.append(i)
	if zombie_row_pool_i.is_empty():
		print("无水路,无法生成珊瑚僵尸")
		return

	var zombie_type_sea_weed_list :Array= [CharacterRegistry.ZombieType.Z001Norm, CharacterRegistry.ZombieType.Z003Cone, CharacterRegistry.ZombieType.Z005Bucket]

	for i in range(3):
		var zombie_type:CharacterRegistry.ZombieType = zombie_type_sea_weed_list.pick_random()
		var lane:int= zombie_row_pool_i.pick_random()
		var zombie_sea_weed:Zombie000Base = wave_create_zombie(zombie_type, lane, -1, _zombie_seaweed)

		if is_instance_valid(zombie_sea_weed):
			zombie_sea_weed.global_position.x = randf_range(500, 750)

func _zombie_seaweed(z:Zombie001Norm):
	z.is_seaweed = true

func spawn_bungi_zombies():
	var num_bungi_rand:int = randi_range(range_num_bungi.x, range_num_bungi.y)
	var all_cell_have_plant:Array[PlantCell] = zombie_manager.main_game.plant_cell_manager.get_cell_have_plant()
	var num_bungi_res:int = min(num_bungi_rand, all_cell_have_plant.size())
	all_cell_have_plant.shuffle()
	var all_cell_be_bungi = all_cell_have_plant.slice(0, num_bungi_res)
	for plant_cell:PlantCell in all_cell_be_bungi:
		var zombie_init_para:Dictionary = {
			Zombie000Base.E_ZInitAttr.CharacterInitType:Character000Base.E_CharacterInitType.IsNorm,
			Zombie000Base.E_ZInitAttr.Lane:plant_cell.row_col.x
		}

		zombie_manager.create_norm_zombie(
			CharacterRegistry.ZombieType.Z021Bungi,
			zombie_manager.all_zombie_rows[plant_cell.row_col.x],
			zombie_init_para,
			Vector2(plant_cell.global_position.x + plant_cell.size.x/2,
				zombie_manager.all_zombie_rows[plant_cell.row_col.x].zombie_create_position.global_position.y
			),
			GlobalUtils.create_bungi.bind(plant_cell)
		)
#endregion
