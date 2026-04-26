extends Control

func _ready() -> void:
	NetworkHandler.lobby_list_updated.connect(func(lobbies):
		var selection = %LobbyList.get_selected_items()
		%LobbyList.clear();
		if not lobbies: return
		lobbies = lobbies as Array
		lobbies.sort_custom(func(a: HLobby,b: HLobby):
			return a['lobby_id'] > b['lobby_id']
		)
		for lobby in lobbies: %LobbyList.add_item(lobby.lobby_id)
		if selection:
			%LobbyList.select(selection[0])
	)
	%ConnectButton.pressed.connect(func():
		var selection = %LobbyList.get_selected_items()
		if not selection: return
		var selected_lobby_id: String = %LobbyList.get_item_text(selection[0])
		NetworkHandler.join_lobby_by_id(selected_lobby_id)
	)
	%HostButton.pressed.connect(NetworkHandler.create_lobby)
	
	EOS.get_instance().logging_interface_callback.connect(func(msg):
		msg = EOS.Logging.LogMessage.from(msg) as EOS.Logging.LogMessage
		%DeepLog.add_text("SDK %s | %s" % [msg.category, msg.message] + '\n' )
	)
	NetworkHandler.log_callback.connect(func(msg):
		%OverviewLog.add_text(msg + '\n')
	)
	
	await NetworkHandler.sdk_initialized
	%UpdateLobbiesList.start()
	
func _on_peer_pressed() -> void:
	NetworkHandler.search_lobbies()

func _on_update_lobbies_list_timeout() -> void:
	NetworkHandler.search_lobbies()
