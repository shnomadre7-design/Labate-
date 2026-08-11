extends Node

const PORT = 8910
const MAX_PLAYERS = 5

var peer = ENetMultiplayerPeer.new()

signal player_connected(id)
signal player_disconnected(id)

# إنشاء غرفة (اللاعب الأول - Host)
func create_host():
    var error = peer.create_server(PORT, MAX_PLAYERS)
    if error == OK:
        multiplayer.multiplayer_peer = peer
        multiplayer.peer_connected.connect(_on_player_connected)
        multiplayer.peer_disconnected.connect(_on_player_disconnected)
        print("تم إنشاء الغرفة بنجاح. بانتظار اللاعبين...")

# الانضمام إلى غرفة عن طريق الـ IP (باقي اللاعبين - Clients)
func join_game(ip_address: String):
    if ip_address == "":
        ip_address = "127.0.0.1" # افتراضي للإنعكاس الداخلي
    
    var error = peer.create_client(ip_address, PORT)
    if error == OK:
        multiplayer.multiplayer_peer = peer
        print("جاري الاتصال بـ: ", ip_address)

func _on_player_connected(id):
    emit_signal("player_connected", id)

func _on_player_disconnected(id):
    emit_signal("player_disconnected", id)
