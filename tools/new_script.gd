@tool
extends EditorScript

## 50 关冒险模式关卡数据生成器
## 运行方式：脚本编辑器里按 Ctrl+Shift+X

const OUTPUT_DIR := "res://resources/level_date_resource/mode_adventure/"

const LEVELS := {
	# ===== 第 1 大关：白天前院 =====
	"adventure_1_01": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1]},
	"adventure_1_02": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3]},
	"adventure_1_03": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3]},
	"adventure_1_04": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3, 4]},
	"adventure_1_05": {"sences": 0, "bg": 0, "bgm": 0, "wave": 20, "zombies": [1, 3, 4]},
	"adventure_1_06": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3, 4, 5]},
	"adventure_1_07": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3, 4, 5]},
	"adventure_1_08": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3, 4, 5, 6]},
	"adventure_1_09": {"sences": 0, "bg": 0, "bgm": 0, "wave": 10, "zombies": [1, 3, 4, 5, 6]},
	"adventure_1_10": {"sences": 0, "bg": 0, "bgm": 0, "wave": 20, "zombies": [1, 3, 4, 5, 6]},

	# ===== 第 2 大关：黑夜前院 =====
	"adventure_2_01": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_02": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_03": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_04": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4, 5], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_05": {"sences": 0, "bg": 1, "bgm": 1, "wave": 20, "zombies": [1, 3, 4, 5], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_06": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4, 5, 6], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_07": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4, 5, 6, 7], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_08": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4, 5, 6, 7, 9], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_09": {"sences": 0, "bg": 1, "bgm": 1, "wave": 10, "zombies": [1, 3, 4, 5, 6, 7, 8], "extra": {"is_day": false, "is_day_sun": false}},
	"adventure_2_10": {"sences": 0, "bg": 1, "bgm": 1, "wave": 20, "zombies": [1, 3, 4, 5, 6, 7, 8, 9], "extra": {"is_day": false, "is_day_sun": false}},

	# ===== 第 3 大关：泳池 =====
	"adventure_3_01": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3]},
	"adventure_3_02": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4]},
	"adventure_3_03": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5]},
	"adventure_3_04": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5, 6]},
	"adventure_3_05": {"sences": 1, "bg": 2, "bgm": 2, "wave": 20, "zombies": [1, 3, 4, 5, 6]},
	"adventure_3_06": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5, 6, 13]},
	"adventure_3_07": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5, 6, 13, 14]},
	"adventure_3_08": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5, 6, 13, 14, 15]},
	"adventure_3_09": {"sences": 1, "bg": 2, "bgm": 2, "wave": 10, "zombies": [1, 3, 4, 5, 6, 13, 14, 15]},
	"adventure_3_10": {"sences": 1, "bg": 2, "bgm": 2, "wave": 20, "zombies": [1, 3, 4, 5, 6, 13, 14, 15]},

	# ===== 第 4 大关：迷雾 =====
	"adventure_4_01": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_02": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_03": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_04": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12, 15], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_05": {"sences": 1, "bg": 3, "bgm": 3, "wave": 20, "zombies": [1, 3, 5, 12, 15], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_06": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12, 15, 16], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_07": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12, 15, 16, 17], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_08": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12, 15, 16, 17, 18], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_09": {"sences": 1, "bg": 3, "bgm": 3, "wave": 10, "zombies": [1, 3, 5, 12, 15, 16, 17, 18], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},
	"adventure_4_10": {"sences": 1, "bg": 3, "bgm": 3, "wave": 20, "zombies": [1, 3, 5, 12, 15, 16, 17, 18, 19], "extra": {"is_fog": true, "is_day": false, "is_day_sun": false}},

	# ===== 第 5 大关：屋顶 =====
	"adventure_5_01": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3]},
	"adventure_5_02": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5]},
	"adventure_5_03": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19]},
	"adventure_5_04": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19, 16]},
	"adventure_5_05": {"sences": 2, "bg": 4, "bgm": 4, "wave": 20, "zombies": [1, 3, 5, 19, 16]},
	"adventure_5_06": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19, 16, 7]},
	"adventure_5_07": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19, 16, 7, 22]},
	"adventure_5_08": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19, 16, 7, 22, 23]},
	"adventure_5_09": {"sences": 2, "bg": 4, "bgm": 4, "wave": 10, "zombies": [1, 3, 5, 19, 16, 7, 22, 23]},
	"adventure_5_10": {"sences": 2, "bg": 4, "bgm": 4, "wave": 20, "zombies": [1, 3, 5, 19, 16, 7, 22, 23, 24]},
}

func _run() -> void:
	print("=== 开始生成 50 关 ===")

	var count := 0
	for level_name in LEVELS:
		var cfg: Dictionary = LEVELS[level_name]
		var res := ResourceLevelData.new()
		res.game_sences = cfg["sences"]
		res.game_BG = cfg["bg"]
		res.game_BGM = cfg["bgm"]
		res.max_wave = cfg["wave"]

		# 僵尸列表：显式转换成 typed array
		var zlist: Array[CharacterRegistry.ZombieType] = []
		for z in cfg["zombies"]:
			zlist.append(z as CharacterRegistry.ZombieType)
		res.zombie_refresh_types = zlist

		if cfg.has("extra"):
			var extra: Dictionary = cfg["extra"]
			for key in extra:
				res.set(key, extra[key])

		var path: String = OUTPUT_DIR + str(level_name) + ".tres"
		var err := ResourceSaver.save(res, path)
		if err == OK:
			count += 1
			print("已生成：", path)
		else:
			push_error("保存失败：" + path + "，错误码：" + str(err))

	print("=== 完成，共生成 ", count, " 个关卡文件 ===")
