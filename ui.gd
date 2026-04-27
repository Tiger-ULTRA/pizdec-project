extends Control

func _ready() -> void:
	
	NetworkHandler.lobby_list_updated.connect(func update_lobby_list(lobbies):
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
	
	NetworkHandler.connected_to_lobby.connect(func switch_lo_inlobby_ui(lobby: HLobby, is_host: bool):
		%NetworkStatusUI.current_tab = 1
		%InLobbyInfo.text = "Currently in lobby: %s\n%s" % [lobby.lobby_id, "HOST" if is_host else "PEER"]
		%HostButton.disabled = false
		%ConnectButton.disabled = false
	)
	
	NetworkHandler.connection_to_lobby_failed.connect(func allow_lobbies_interaction():
		%NetworkStatusUI.current_tab = 0
		%HostButton.disabled = false
		%ConnectButton.disabled = false
	)
	%ConnectButton.pressed.connect(func connect_to_selected_lobby():
		var selection = %LobbyList.get_selected_items()
		if not selection: return
		%HostButton.disabled = true
		%ConnectButton.disabled = true
		var selected_lobby_id: String = %LobbyList.get_item_text(selection[0])
		NetworkHandler.join_lobby_by_id(selected_lobby_id)
	)
	%HostButton.pressed.connect(func host_lobby():
		%HostButton.disabled = true
		%ConnectButton.disabled = true
		NetworkHandler.create_lobby()
	)
	
	EOS.get_instance().logging_interface_callback.connect(func(msg):
		msg = EOS.Logging.LogMessage.from(msg) as EOS.Logging.LogMessage
		%DeepLog.add_text("SDK %s | %s" % [msg.category, msg.message] + '\n' )
	)
	
	NetworkHandler.log_callback.connect(func(msg):
		%OverviewLog.add_text(msg + '\n')
	)
	
	%LeaveLobbyButton.pressed.connect(func leave_current_lobby():
		NetworkHandler.leave_current_lobby()
		%NetworkStatusUI.current_tab = 0
	)
	
	await NetworkHandler.sdk_initialized
	%HostButton.disabled = false
	%ConnectButton.disabled = false
	%UpdateLobbiesList.start()
	
func _on_peer_pressed() -> void:
	NetworkHandler.search_lobbies()

func _on_update_lobbies_list_timeout() -> void:
	NetworkHandler.search_lobbies()
