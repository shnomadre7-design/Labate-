extends CharacterBody2D

var owner_id : int
var speed : float = 100.0
var hp : int = 50
var damage : int = 10

# النقطة المركزية التي يجب التوجه إليها (القاعدة)
var target_position = Vector2.ZERO 

func _physics_process(delta):
    # توجيه الجندي نحو المركز دائماً
    var direction = global_position.direction_to(target_position)
    velocity = direction * speed
    move_and_slide()

func take_damage(amount: int):
    hp -= amount
    if hp <= 0:
        queue_free() # حذف الجندي من الخريطة عند موته
