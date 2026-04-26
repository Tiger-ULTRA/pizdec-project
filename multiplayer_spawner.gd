extends MultiplayerSpawner

@export var network_player: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int):
	if not multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	
	get_node(spawn_path).call_deferred("add_child", player) 
