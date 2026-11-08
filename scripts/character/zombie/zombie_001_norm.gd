extends Zombie000Base
class_name Zombie001Norm

@onready var anim_innerarm: Node2D = $Body/BodyCorrect/Anim_innerarm
@onready var zombie_outerarm_upper: Node2D = $Body/BodyCorrect/Zombie_outerarm_upper

@export_group("动画状态")
## 动画状态（僵尸有某类动画有多种）
@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

@export_subgroup("最大动画状态")
@export var idle_status_max := 2
@export var walk_status_max := 2
@export var death_status_max := 2

@export_group("普僵初始化精灵节点")
@export var init_sprite_random:Array[Node2D]

## 海草精灵节点
@onready var sprite_seaweed:Array[Sprite2D] = [
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed3,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed2,
	$Body/BodyCorrect/Zombie_outerarm_upper/Zombie_outerarm_upper/ZombieSeaweed4,
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed2,
]
## 铁桶海草精灵
@onready var sprite_seaweed_bucket: Sprite2D = $Body/BodyCorrect/Anim_bucket/Anim_bucket/ZombieSeaweed4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_random_anim_status()
	_random_sprit_appear()
	if is_seaweed:
		sprite_seaweed.shuffle()
		var pick3 = sprite_seaweed.slice(0, 3)
		for s in pick3:
			s.visible = true
		sprite_seaweed_bucket.visible = true

## 随机选择动画状态种类
func _random_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _random_sprit_appear():
	for sprite in init_sprite_random:
		sprite.visible = [true, false].pick_random()


## 死亡动画开始时,将里面的胳膊显示(旗帜\铁门)
func anim_death_start():
	anim_innerarm.visible = true

# ================= 神·僵尸外挂 =================
var is_ghosting: bool = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		_setup_super_zombie.call_deferred()

func _setup_super_zombie() -> void:
	var hp = get_node_or_null("HpComponent")
	if hp:
		if not hp.signal_hp_loss.is_connected(_on_damage): hp.signal_hp_loss.connect(_on_damage)
		if not hp.signal_hp_component_death.is_connected(_on_death): hp.signal_hp_component_death.connect(_on_death)

func _on_damage(curr_hp, is_drop):
	if is_ghosting or is_death: return
	if randf() < 0.3:
		is_ghosting = true
		modulate.a = 0.4
		global_position.x -= 160
		get_tree().create_timer(0.5).timeout.connect(_end_ghost)
		var hp = get_node_or_null("HpComponent")
		if is_instance_valid(hp): hp.curr_hp += 20

func _end_ghost():
	if is_instance_valid(self) and not is_death:
		is_ghosting = false
		modulate.a = 1.0

func _on_death():
	if get_meta("has_burst", false): return
	set_meta("has_burst", true)
	var zt = int(zombie_type)
	if zt == 5: _spawn_minions(4, 3) # 铁桶(5) 爆 4个 路障(3)
	elif zt == 3: _spawn_minions(8, 1) # 路障(3) 爆 8个 普僵(1)

func _spawn_minions(count, z_type):
	call_deferred("_do_spawn", count, z_type)

func _do_spawn(count, z_type):
	var zm = get_tree().root.find_child("ZombieManager", true, false)
	if zm and "all_zombie_rows" in zm:
		var row = lane
		if row < zm.all_zombie_rows.size():
			for i in range(count):
				# 【核心修复】X轴绝对只能往右偏 (10 到 100 像素)，防止生成在植物后面
				# Y轴偏移限制在 (-20 到 20)，确保依旧处于同一行，不会被算作死角
				var pos = global_position + Vector2(randf_range(10, 100), randf_range(-20, 20))
				
				var para = {
					Zombie000Base.E_ZInitAttr.CharacterInitType: Character000Base.E_CharacterInitType.IsNorm,
					Zombie000Base.E_ZInitAttr.Lane: row,
					Zombie000Base.E_ZInitAttr.CurrWave: 1
				}
				zm.create_norm_zombie(z_type, zm.all_zombie_rows[row], para, pos)
