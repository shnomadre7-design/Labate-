extends Node

var dirhams : int = 0
var income_rate : int = 5 # كم درهم يضاف في الثانية
var upgrade_cost : int = 100

signal dirhams_updated(new_amount)

func _ready():
    # إنشاء مؤقت يضيف دراهم كل ثانية
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.autostart = true
    timer.timeout.connect(_on_timer_timeout)
    add_child(timer)

func _on_timer_timeout():
    add_dirhams(income_rate)

func add_dirhams(amount: int):
    dirhams += amount
    emit_signal("dirhams_updated", dirhams)

func spend_dirhams(amount: int) -> bool:
    if dirhams >= amount:
        dirhams -= amount
        emit_signal("dirhams_updated", dirhams)
        return true
    return false

# دالة تطوير سرعة الجمع
func upgrade_income():
    if spend_dirhams(upgrade_cost):
        income_rate += 5
        upgrade_cost *= 2 # مضاعفة سعر التطوير القادم ليصبح أصعب
