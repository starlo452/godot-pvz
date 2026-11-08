extends Plant000Base
class_name Plant002SunFlower

@onready var create_sun_component: CreateSunComponent = $CreateSunComponent


func ready_norm() -> void:
	super()
	if is_zombie_mode:
		create_sun_component.disable_component(ComponentNormBase.E_IsEnableFactor.GameMode)

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(create_sun_component.owner_update_speed)


## 被僵尸啃食一次特殊效果,魅惑\大蒜\我是僵尸生产阳光
func _be_zombie_eat_once_special(_attack_zombie:Zombie000Base):
	if is_zombie_mode:
		create_sun_component._on_be_eat_once()

## 植物死亡
func character_death():
	if is_zombie_mode:
		create_sun_component._on_character_death()
	super()

# ================= 神·向日葵印钞外挂 =================
var fast_sun_timer: Timer
var sun_scene = preload("res://scenes/item/game_scenes_item/sun.tscn")

func _ready() -> void:
	super._ready()
	call_deferred("_setup_sunflower_super")

func _setup_sunflower_super():
	if has_node("CreateSunComponent"):
		$CreateSunComponent.set_process(false)
		$CreateSunComponent.set_physics_process(false)
		
	for child in get_children():
		if "sun" in child.name.to_lower() or "create" in child.name.to_lower():
			child.set_process(false)
			child.set_physics_process(false)
			for grandchild in child.get_children():
				if grandchild is Timer:
					grandchild.stop()

	_burst_sun(40)
	
	fast_sun_timer = Timer.new()
	fast_sun_timer.wait_time = 2.0
	fast_sun_timer.autostart = true
	fast_sun_timer.timeout.connect(func(): _spawn_single_sun())
	add_child(fast_sun_timer)

func _burst_sun(count: int) -> void:
	for i in range(count):
		_spawn_single_sun(i)

func _spawn_single_sun(index: int = 0) -> void:
	if not is_instance_valid(Global.main_game) or sun_scene == null: return
		
	var sun = sun_scene.instantiate()
	Global.main_game.add_child(sun)
	
	if "is_can_collect" in sun: sun.is_can_collect = false
	sun.set_process_input(false)
	sun.set_process_unhandled_input(false)
	
	var random_offset = Vector2(randf_range(-60, 60), randf_range(-40, 20))
	sun.global_position = global_position + Vector2(0, -50) + random_offset
	
	var target_pos = Vector2(100, 50) 
	var target_node = get_tree().root.find_child("Marker2DSunTarget", true, false)
	if target_node: target_pos = target_node.global_position
		
	var tween = create_tween()
	tween.set_parallel(true)
	
	var burst_target = sun.global_position + Vector2(randf_range(-150, 150), randf_range(-100, 100))
	tween.tween_property(sun, "global_position", burst_target, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var fly_tween = create_tween()
	fly_tween.tween_interval(0.4 + randf_range(0.0, 0.3))
	fly_tween.tween_property(sun, "global_position", target_pos, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	fly_tween.tween_callback(func():
		EventBus.push_event("add_sun_value", 25)
		sun.queue_free()
	)
