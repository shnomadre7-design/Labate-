extends Control

@onready var winner_label = $VBoxContainer/WinnerLabel
@onready var restart_button = $VBoxContainer/RestartButton

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	
	# عرض اسم أو رقم اللاعب الذي صمد 10 دقائق
	var winner_id = GameManager.current_controller_id
	if winner_id != -1:
		winner_label.text = "مبروك! الفائز بالسيطرة هو اللاعب رقم: " + str(winner_id)
	else:
		winner_label.text = "انتهت المعركة!"

func _on_restart_pressed():
	# إعادة تصفير العدادات والعودة للقائمة الرئيسية
	GameManager.time_held = 0.0
	GameManager.current_controller_id = -1
	SceneManager.change_scene("res://UI/MainMenu.gd")
