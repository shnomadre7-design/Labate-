extends Area2D

# قاموس لتسجيل عدد جيوش كل لاعب داخل الدائرة
var troops_in_base = {}

func _on_body_entered(body):
    if body.is_in_group("Troops"):
        var player_id = body.owner_id
        if not troops_in_base.has(player_id):
            troops_in_base[player_id] = 0
        troops_in_base[player_id] += 1
        check_control()

func _on_body_exited(body):
    if body.is_in_group("Troops"):
        var player_id = body.owner_id
        troops_in_base[player_id] -= 1
        if troops_in_base[player_id] <= 0:
            troops_in_base.erase(player_id)
        check_control()

func check_control():
    if troops_in_base.size() == 1:
        # لاعب واحد فقط بالداخل، نعطيه السيطرة
        var controller_id = troops_in_base.keys()[0]
        GameManager.change_controller(controller_id)
    else:
        # إما فارغة أو بها قتال بين جيشين، تتوقف السيطرة
        GameManager.change_controller(-1)
