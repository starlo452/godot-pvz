extends Plant000Base
class_name Plant001PeaShooterSingle

@onready var attack_component: AttackComponentBulletBase = $AttackComponent


## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
# ================= 神·豌豆核爆外挂 =================
var attack_timer: Timer
var bullet_scene = preload("res://scenes/bullet/bullet_001_pea.tscn")

func _ready() -> void:
	super._ready()
	# 延迟一帧封印原版组件，绝不打断动画
	call_deferred("_setup_pea_super")

func _setup_pea_super():
	if has_node("AttackComponent"):
		var comp = $AttackComponent
		comp.process_mode = Node.PROCESS_MODE_DISABLED
		comp.set_process(false)
		comp.set_physics_process(false)
		for child in comp.get_children():
			if child is Timer: child.stop()
				
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.4
	attack_timer.autostart = true
	attack_timer.timeout.connect(_on_attack_timer)
	add_child(attack_timer)

func _on_attack_timer() -> void:
	if not is_instance_valid(Global.main_game): return
	if not _has_zombie_ahead(): return
		
	var bullet = bullet_scene.instantiate()
	Global.main_game.add_child(bullet)
	bullet.global_position = global_position + Vector2(30, -20)
	if "direction" in bullet: bullet.direction = Vector2(1, 0)
		
	var is_exploded = [false]
	for child in bullet.get_children():
		if child is Area2D:
			child.area_entered.connect(func(area):
				if is_exploded[0]: return
				if area.owner is Zombie000Base or area.owner is Character000Base:
					is_exploded[0] = true
					_trigger_doom_explosion(area.owner.global_position)
			)

func _has_zombie_ahead() -> bool:
	var zombies = get_tree().root.find_children("*", "Zombie000Base", true, false)
	for z in zombies:
		if is_instance_valid(z) and not z.is_queued_for_deletion():
			if z.global_position.x > global_position.x and abs(z.global_position.y - global_position.y) < 80:
				return true
	return false

func _trigger_doom_explosion(center_pos: Vector2) -> void:
	var zombies = get_tree().root.find_children("*", "Zombie000Base", true, false)
	for z in zombies:
		if is_instance_valid(z) and not z.is_queued_for_deletion():
			if abs(z.global_position.x - center_pos.x) < 200 and abs(z.global_position.y - center_pos.y) < 200:
				if z.has_method("be_attacked_bullet"):
					z.be_attacked_bullet(1800, BulletRegistry.AttackMode.Real, true, true)
					
	var tex = load("res://assets/image/particles/bullet/DoomShroom_Explosion_Top.png")
	if tex != null:
		var fx = Sprite2D.new()
		fx.texture = tex
		fx.global_position = center_pos
		fx.z_index = 10 
		fx.scale = Vector2(0.01, 0.01)
		fx.modulate.a = 0.0
		Global.main_game.add_child(fx)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(fx, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(fx, "modulate:a", 0.9, 0.1)
		tween.tween_property(fx, "scale", Vector2(0.4, 0.4), 0.4).set_delay(0.3)
		tween.tween_property(fx, "modulate:a", 0.0, 0.4).set_delay(0.3)
		tween.chain().tween_callback(fx.queue_free)
