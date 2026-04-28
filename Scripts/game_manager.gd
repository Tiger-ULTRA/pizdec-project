extends Node

var player_list: Array[Player]
var minigames_list: Array[PackedScene]

const MINIGAMES_FOLDER: String = "res://Minigames/"

signal all_players_ready
signal not_all_player_ready

func _ready() -> void:
	_update_minigames_list()

func _update_minigames_list():
	var directory = DirAccess.open(MINIGAMES_FOLDER)
	directory.list_dir_begin()
	var file = directory.get_next()
	while file:
		if file.get_extension() == "tscn":
			minigames_list.append(load(MINIGAMES_FOLDER.path_join(file)))
		file = directory.get_next()

@rpc("call_local")
func start_game():
	get_tree().change_scene_to_packed(minigames_list.pick_random())
	

func _check_all_ready():
	for player in player_list:
		if not player.is_ready:
			not_all_player_ready.emit()
			return
	all_players_ready.emit()
