extends Node
#
#const RELAY_SERVER: String = "eu_central.nodetunnel.io:8080"
#const APP_ID: String = "m7mprn3x96yecy9"
#
#var peer: NodeTunnelPeer
#
#func _ready() -> void:
	#peer = NodeTunnelPeer.new()
	#
	#peer.error.connect(func(error_msg): push_error("NodeTunnel Error: ", error_msg))
#
	#peer.connect_to_relay(RELAY_SERVER, APP_ID)
	#multiplayer.multiplayer_peer = peer
	#
	#print("Authenticating...")
	#await peer.authenticated
	#print("Authenticated!")
	#
	#var args = OS.get_cmdline_args()
	#if "--server" in args:
		#start_server()
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
#
	#if "--debug_peer" in args:
		#await get_tree().create_timer(3).timeout
		#join_room(DisplayServer.clipboard_get())
	#
#func start_server() -> void:
	#peer.host_room(true, "name: YOY")
	#
	#print("Hosting room...")
	#await peer.room_connected
	#print("Hosted room: ", peer.room_id)
	#
	#DisplayServer.clipboard_set(peer.room_id)
	#
#func join_room(room_id: String) -> void:
	#peer.join_room(room_id)
	#
	#print("NH Connecting to room: ", room_id)
	#await peer.room_connected
	#print("NH Connected to room: ", peer.room_id)
