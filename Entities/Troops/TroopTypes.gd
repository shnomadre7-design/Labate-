class_name TroopTypes
extends Node

enum Type { INFANTRY, CAVALRY, ARCHER, TANK }

# بيانات كل نوع جيش: [التكلفة، نقاط الحياة، السرعة، قوة الهجوم]
static func get_stats(type: Type) -> Dictionary:
    match type:
        Type.INFANTRY: # مشاة (رخيص ومتوازن)
            return {"cost": 15, "hp": 50, "speed": 100.0, "damage": 10}
        Type.CAVALRY:  # فرسان (سريع جداً ومكلف)
            return {"cost": 35, "hp": 80, "speed": 180.0, "damage": 15}
        Type.ARCHER:   # رماة (ضعيف HP لكن قوي)
            return {"cost": 25, "hp": 30, "speed": 90.0,  "damage": 25}
        Type.TANK:     # مدرع (بطيء جداً وصامد)
            return {"cost": 50, "hp": 150, "speed": 60.0,  "damage": 8}
        _:
            return {"cost": 10, "hp": 10, "speed": 100.0, "damage": 5}
