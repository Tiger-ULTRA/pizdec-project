extends MultiplayerSpawner

@export var network_player: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	NetworkHandler.hosted_lobby.connect(spawn_player.bind(1))
	
	multiplayer.peer_disconnected.connect(despawn_player)
	NetworkHandler.closed_lobby.connect(despawn_player.bind(1))

func spawn_player(id: int):
	if not multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	GameManager.player_list.append(player)
	get_node(spawn_path).call_deferred("add_child", player) 

func despawn_player(id: int):
	var player = get_node(spawn_path).get_node(str(id))
	GameManager.player_list.erase(player)
	player.queue_free()
