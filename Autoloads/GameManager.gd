extends Node

var winning_time_required : float = 600.0 # 10 دقائق بالثواني
var current_controller_id : int = -1
var time_held : float = 0.0

signal base_controller_changed(new_controller_id)
signal game_won(winner_id)

func _ready():
	# ربط حدث الفوز بنقل الشاشة
	game_won.connect(_on_game_won)

func _process(delta):
	if current_controller_id != -1:
		time_held += delta
		if time_held >= winning_time_required:
			emit_signal("game_won", current_controller_id)
			set_process(false)

func change_controller(player_id: int):
	if current_controller_id != player_id:
		current_controller_id = player_id
		time_held = 0.0
		emit_signal("base_controller_changed", player_id)

func _on_game_won(_winner_id: int):
	# التحويل لشاشة الفوز فوراً
	SceneManager.change_scene("res://UI/GameOver.gd")
