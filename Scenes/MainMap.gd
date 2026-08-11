extends Node2D

@export var troop_scene: PackedScene

# موقع القاعدة المركزية (منتصف الشاشة)
var center_position = Vector2(640, 360) 
var radius = 250.0 # المسافة بين كل مملكة والقاعدة

func _ready():
    setup_pentagon_positions()

# حساب أماكن الممالك الـ 5 على شكل خماسي منتظم
func setup_pentagon_positions():
    for i in range(5):
        # تقسيم الدائرة (360 درجة) على 5 ممالك
        var angle = i * (2 * PI / 5) - (PI / 2) # إزاحة لجعل إحدى الممالك في الأعلى
        var kingdom_pos = center_position + Vector2(cos(angle), sin(angle)) * radius
        print("موقع المملكة ", i + 1, " هو: ", kingdom_pos)

# دالة إرسال جيش من مملكة لاعب معين
func spawn_troop(player_id: int, troop_type: TroopTypes.Type, spawn_pos: Vector2):
    var stats = TroopTypes.get_stats(troop_type)
    
    # التأكد من امتلاك اللاعب للمبلغ K
    if EconomyManager.spend_dirhams(stats["cost"]):
        var new_troop = troop_scene.instantiate()
        new_troop.owner_id = player_id
        new_troop.hp = stats["hp"]
        new_troop.speed = stats["speed"]
        new_troop.damage = stats["damage"]
        new_troop.global_position = spawn_pos
        new_troop.target_position = center_position
        
        add_child(new_troop)
