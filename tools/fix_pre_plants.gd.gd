@tool
extends EditorScript

func _run() -> void:
	var dir_path = "res://resources/level_date_resource/mode_adventure/"
	var dir = DirAccess.open(dir_path)
	if dir == null: 
		push_error("找不到目录：" + dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var count = 0
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var path = dir_path + file_name
			# 加载资源
			var res = load(path) as ResourceLevelData
			
			if res != null:
				# 创建一个全新的数组，避开只读限制
				var new_data: Array[PrePlantResource] = []
				
				# ================= 屋顶关卡：第一列全加花盆 =================
				if file_name.begins_with("adventure_5_"):
					for row in range(5):
						var pre_plant = load("res://scripts/resources/level/pre_plant_in_level.gd").new() as PrePlantResource
						pre_plant.plant_type = 34 # 花盆
						pre_plant.plant_cell_pos = Vector2i(0, row) # 第一列
						new_data.append(pre_plant)
					
				# ================= 泳池关卡：第一列全加睡莲 =================
				elif file_name.begins_with("adventure_3_") or file_name.begins_with("adventure_4_"):
					for row in range(5):
						if row == 2 or row == 3: # 泳池只有中间两行是水
							var pre_plant = load("res://scripts/resources/level/pre_plant_in_level.gd").new() as PrePlantResource
							pre_plant.plant_type = 17 # 睡莲
							pre_plant.plant_cell_pos = Vector2i(0, row) # 第一列
							new_data.append(pre_plant)
							
				# 直接覆盖赋值给原来的属性
				res.all_pre_plant_data = new_data
				
				# 保存
				var err = ResourceSaver.save(res, path)
				if err == OK:
					count += 1
					print("成功更新: ", file_name)
				else:
					print("保存失败: ", file_name)
					
		file_name = dir.get_next()
		
	dir.list_dir_end()
	print("========================================")
	print("修复完成！共成功更新了 ", count, " 个关卡的花盆/睡莲配置！")
	print("========================================")
