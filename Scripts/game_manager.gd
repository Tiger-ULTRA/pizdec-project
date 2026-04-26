extends Node

# Словарь вида { peer_id: { "name": "Player1", "is_ready": false } }
var players: Dictionary = {}

signal player_list_changed
signal all_players_ready

func toggle_ready(ready_state: bool):
	var id = multiplayer.get_remote_sender_id()
	if players.has(id):
		players[id].is_ready = ready_state
		player_list_changed.emit()
		_check_all_ready()

func _check_all_ready():
	if players.size() > 1 and players.values().all(func(p): return p.is_ready):
		all_players_ready.emit()
