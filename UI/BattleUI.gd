extends CanvasLayer

@onready var dirhams_label = $Control/TopBar/DirhamsLabel
@onready var timer_label = $Control/TopBar/TimerLabel

@onready var upgrade_btn = $Control/BottomBar/UpgradeButton
@onready var infantry_btn = $Control/BottomBar/InfantryButton
@onready var cavalry_btn = $Control/BottomBar/CavalryButton
@onready var archer_btn = $Control/BottomBar/ArcherButton
@onready var tank_btn = $Control/BottomBar/TankButton

# المعرف الخاص باللاعب الحالي على الجهاز
var my_player_id : int = 1

func _ready():
	# ربط إشارة تحديث الدراهم بالشاشة
	EconomyManager.dirhams_updated.connect(_on_dirhams_updated)
	
	# ربط ضغطات أزرار اللمس بالأكواد البرمجية
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	infantry_btn.pressed.connect(func(): _spawn_troop(TroopTypes.Type.INFANTRY))
	cavalry_btn.pressed.connect(func(): _spawn_troop(TroopTypes.Type.CAVALRY))
	archer_btn.pressed.connect(func(): _spawn_troop(TroopTypes.Type.ARCHER))
	tank_btn.pressed.connect(func(): _spawn_troop(TroopTypes.Type.TANK))

func _process(_delta):
	# تحديث عداد الوقت المتبقي في أعلى الشاشة
	var minutes = int(GameManager.time_held) / 60
	var seconds = int(GameManager.time_held) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_dirhams_updated(new_amount: int):
	dirhams_label.text = "الدراهم: " + str(new_amount)
	upgrade_btn.text = "تطوير (" + str(EconomyManager.upgrade_cost) + " درهم)"

func _on_upgrade_pressed():
	EconomyManager.upgrade_income()

func _spawn_troop(troop_type: TroopTypes.Type):
	var main_map = get_tree().current_scene
	if main_map and main_map.has_method("spawn_troop"):
		# جلب موقع الانطلاق الخاص بملكيتك وإرسال الجيش
		var spawn_pos = main_map.get_player_spawn_position(my_player_id)
		main_map.spawn_troop(my_player_id, troop_type, spawn_pos)
