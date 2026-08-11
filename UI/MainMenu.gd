extends Control

@onready var player_name_input = $VBoxContainer/PlayerNameInput
@onready var ip_input = $VBoxContainer/IPInput
@onready var host_button = $VBoxContainer/HostButton
@onready var join_button = $VBoxContainer/JoinButton
@onready var status_label = $VBoxContainer/StatusLabel

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
	# الاستماع لإشارات الاتصال من NetworkManager
	NetworkManager.player_connected.connect(_on_player_connected)

func _on_host_pressed():
	var player_name = player_name_input.text.strip_edges()
	if player_name == "":
		status_label.text = "يرجى إدخال اسمك أولاً!"
		return
		
	status_label.text = "جاري إنشاء الغرفة..."
	NetworkManager.create_host()
	# الانتقال لمشهد الخريطة الرئيسية بعد التجهيز
	SceneManager.change_scene("res://Scenes/MainMap.tscn")

func _on_join_pressed():
	var player_name = player_name_input.text.strip_edges()
	var target_ip = ip_input.text.strip_edges()
	
	if player_name == "":
		status_label.text = "يرجى إدخال اسمك أولاً!"
		return
		
	status_label.text = "جاري الاتصال..."
	NetworkManager.join_game(target_ip)

func _on_player_connected(id):
	status_label.text = "تم الاتصال بنجاح! جاري تحميل اللعبة..."
	SceneManager.change_scene("res://Scenes/MainMap.tscn")
