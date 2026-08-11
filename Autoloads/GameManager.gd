extends Node

# متغيرات الفوز
var winning_time_required : float = 600.0 # 10 دقائق بالثواني
var current_controller_id : int = -1 # -1 تعني لا أحد يسيطر
var time_held : float = 0.0

# إشارات (Signals) لتحديث الواجهة وإعلان الفوز
signal base_controller_changed(new_controller_id)
signal game_won(winner_id)

func _process(delta):
    if current_controller_id != -1:
        time_held += delta
        if time_held >= winning_time_required:
            emit_signal("game_won", current_controller_id)
            set_process(false) # إيقاف الحساب بعد الفوز

# دالة تستدعيها القاعدة المركزية عند تغير المسيطر
func change_controller(player_id: int):
    if current_controller_id != player_id:
        current_controller_id = player_id
        time_held = 0.0 # تصفير العداد للاعب الجديد
        emit_signal("base_controller_changed", player_id)
