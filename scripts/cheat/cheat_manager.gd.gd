extends Node

var is_creative_mode: bool = false
var infinite_sun: bool = false
var zero_cooldown: bool = false
var plants_invincible: bool = false
var stop_spawning: bool = false
var continuous_planting: bool = false

func enable_creative_mode():
	is_creative_mode = true
	infinite_sun = true
	zero_cooldown = true
	continuous_planting = true
	print("【系统】创造模式已开启！全卡牌解锁，无限阳光，0 CD！")
	
	if Global.game_para != null:
		Global.game_para.start_sun = 9999
		
	force_give_sun()

func force_give_sun():
	EventBus.push_event("test_change_sun_value", 9999)
	EventBus.push_event("add_sun_value", 9999)
	
	var curr_scene = get_tree().current_scene
	if curr_scene != null:
		var card_manager = curr_scene.find_child("CardManager", true, false)
		if card_manager != null and "card_slot_battle" in card_manager:
			var slot_battle = card_manager.card_slot_battle
			if slot_battle != null and "sun_value" in slot_battle:
				slot_battle.sun_value = 9999
				print("【系统】当前局阳光已强行设为 9999！")

func toggle_invincible():
	plants_invincible = not plants_invincible
	print("【系统】植物无敌：", plants_invincible)

func toggle_stop_spawning():
	stop_spawning = not stop_spawning
	print("【系统】停止出怪：", stop_spawning)

func clear_zombies():
	var zombies = get_tree().root.find_children("*", "Node2D", true, false)
	for z in zombies:
		if z.name.to_lower().contains("zombie") and z.has_method("die"):
			z.die()
		elif z.name.to_lower().contains("zombie"):
			z.queue_free()
	print("【系统】全屏僵尸已清除！")

func change_scene(scene_name: String):
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
	else:
		return
		
	if ResourceLoader.exists(level_data_path):
		Global.game_para = load(level_data_path)
		Global.game_para.game_mode = MainSceneRegistry.MainScenes.ChooseLevelAdventure
		if infinite_sun:
			Global.game_para.start_sun = 9999
		
	if scene_path != "":
		get_tree().change_scene_to_file.call_deferred(scene_path)
