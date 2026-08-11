extends CanvasLayer

# ربط العناصر الموجودة في الشاشة
@onready var dirhams_label = $DirhamsLabel
@onready var upgrade_btn = $UpgradeButton

# مرجع لسكربت الاقتصاد
@export var player_economy: Node 

func _ready():
    # ربط تحديث الدراهم بالشاشة
    if player_economy:
        player_economy.dirhams_updated.connect(update_dirhams_display)
        upgrade_btn.pressed.connect(_on_upgrade_pressed)

func update_dirhams_display(amount: int):
    dirhams_label.text = "الدراهم: " + str(amount)

func _on_upgrade_pressed():
    if player_economy:
        player_economy.upgrade_income()
