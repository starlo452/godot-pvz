# 直接使用路径继承，避免冲突
extends "res://scripts/character/plant/plant_041_gatling_pea.gd"

var custom_attack_timer: Timer
var is_ult_active: bool = false
var ult_duration: float = 5.0
var ult_shot_timer: Timer

func _ready() -> void:
	super._ready()
	
	if attack_component:
		attack_component.set_process(false)
		attack_component.queue_free()
	
	custom_attack_timer = Timer.new()
	custom_attack_timer.wait_time = 1.4 
	custom_attack_timer.autostart = true
	custom_attack_timer.timeout.connect(_on_custom_attack_timeout)
	add_child(custom_attack_timer)
	
	ult_shot_timer = Timer.new()
	ult_shot_timer.wait_time = 0.025
	ult_shot_timer.autostart = false
	ult_shot_timer.timeout.connect(_on_ult_fire)
	add_child(ult_shot_timer)

## 检测前方有没有僵尸
func _has_zombie_ahead() -> bool:
	var zombies = get_tree().root.find_children("*", "Zombie000Base", true, false)
	for z in zombies:
		if not is_instance_valid(z) or z.is_queued_for_deletion():
			continue
		if z.global_position.x > global_position.x and abs(z.global_position.y - global_position.y) < 80:
			return true
	return false

func _on_custom_attack_timeout() -> void:
	if is_ult_active: return
	if not is_instance_valid(Global.main_game) or Global.main_game.main_game_progress != MainGameManager.E_MainGameProgress.MAIN_GAME:
		return
		
	if not _has_zombie_ahead():
		return
		
	if randf() < 0.3:
		_activate_ultimate()
	else:
		_fire_normal_bullet()

## 普通攻击：一次 6 发火焰子弹
func _fire_normal_bullet() -> void:
	var base_spawn_pos = global_position + Vector2(30, -50)
	
	for i in range(6):
		var y_offset = i * 8
		var b = _create_bullet(base_spawn_pos + Vector2(0, y_offset))
		if b:
			b.direction = Vector2(1, 0)

func _activate_ultimate() -> void:
	print("【超级机枪】开启大招：狂暴倾泻 200 发！")
	is_ult_active = true
	ult_shot_timer.start()
	
	get_tree().create_timer(ult_duration).timeout.connect(func():
		is_ult_active = false
		ult_shot_timer.stop()
	)

func _on_ult_fire() -> void:
	var spawn_pos = global_position + Vector2(30, randf_range(-60, -20))
	var b = _create_bullet(spawn_pos)
	if b:
		b.direction = Vector2(1, 0)

## 【终极修复】直接发射火豌豆，彻底绕开原版火炬树桩的 Bug！
func _create_bullet(pos: Vector2) -> Node:
	# 加载原版的火豌豆场景，而不是普通豌豆！
	var bullet_scene = load("res://scenes/bullet/bullet_006_pea_fire.tscn")
	if bullet_scene == null:
		# 兜底方案：如果找不到火豌豆，还是用普通豌豆
		bullet_scene = load("res://scenes/bullet/bullet_001_pea.tscn")
		
	if bullet_scene == null:
		return null
		
	var bullet = bullet_scene.instantiate()
	
	if is_instance_valid(Global.main_game) and "bullet_manager" in Global.main_game:
		Global.main_game.bullet_manager.add_child(bullet)
	else:
		get_parent().add_child(bullet)
		
	# 防止飞到 UI 层，把渲染层级固定住
	bullet.z_index = 10 
	
	bullet.global_position = pos
	bullet.rotation = 0
	if "direction" in bullet:
		bullet.direction = Vector2(1, 0)
	if "velocity" in bullet:
		bullet.velocity = Vector2(400, 0)
	if "speed_vec" in bullet:
		bullet.speed_vec = Vector2(400, 0)
		
	return bullet
