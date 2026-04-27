extends Node2D
class_name EOSNetworkHandler

@onready var peer: EOSGMultiplayerPeer = EOSGMultiplayerPeer.new()

var local_user_id = ""
var is_server = false
var eos_initialised: bool = false

var local_lobby: HLobby

signal lobby_list_updated(lobbies: Array[HLobby])
signal sdk_initialized
signal log_callback(msg: String)
signal connected_to_lobby(lobby: HLobby, is_host: bool)
signal connection_to_lobby_failed

func log_msg(msg: String):
	log_callback.emit(msg + '\n' + '-'.repeat(250))

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	log_msg("Starting...")
	
	if not eos_initialised:
		initialize_EOS_sdk()
		
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	
func initialize_EOS_sdk():
	var init_opts = EOS.Platform.InitializeOptions.new()
	init_opts.product_name = EosCredentials.PRODUCT_NAME
	init_opts.product_version = EosCredentials.PRODUCT_ID

	var init_results = EOS.Platform.PlatformInterface.initialize(init_opts)
	if init_results != EOS.Result.Success:
		printerr("Failed to initialize EOS SDK: " + EOS.result_str(init_results))
		return
	log_msg("EOS Platform initialized!")

	var create_opts = EOS.Platform.CreateOptions.new();\
		create_opts.product_id = EosCredentials.PRODUCT_ID;\
		create_opts.sandbox_id = EosCredentials.SANDBOX_ID;\
		create_opts.deployment_id = EosCredentials.DEPLOYMENT_ID;\
		create_opts.client_id = EosCredentials.CLIENT_ID;\
		create_opts.client_secret = EosCredentials.CLIENT_SECRET;\
		create_opts.encryption_key = EosCredentials.ENCRYPTION_KEY

	EOS.Platform.PlatformInterface.create(create_opts)
	log_msg("EOS Platform created")
	log_msg("Logging in...")

	var res := EOS.Logging.set_log_level(EOS.Logging.LogCategory.AllCategories, EOS.Logging.LogLevel.Info)
	if res != EOS.Result.Success:
		print("Failed to set log level: " + EOS.result_str(res))

	EOS.get_instance().connect_interface_login_callback.connect(_on_connect_login_callback)

	while not await HAuth.login_anonymous_async("User"): await get_tree().create_timer(0.1).timeout
	
	sdk_initialized.emit()
	eos_initialised = true

func exit_game():
	if peer:
		peer.close()
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	if is_server and local_lobby:
		await local_lobby.destroy_async()
	elif local_lobby:
		await local_lobby.leave_async()
	
func _exit_tree() -> void:
	exit_game()

func _on_connect_login_callback(data: Dictionary) -> void:
	if not data.success:
		log_msg("Login failed")
		EOS.print_result(data)
		return
	log_msg("Login successfull: \n	local_user_id = " + data.local_user_id)
	local_user_id = data.local_user_id
	HAuth.product_user_id = local_user_id

func create_lobby():
	var create_opts := EOS.Lobby.CreateLobbyOptions.new()
	create_opts.bucket_id = EosCredentials.PRODUCT_NAME
	create_opts.max_lobby_members = 10

	var new_lobby = await HLobbies.create_lobby_async(create_opts)
	if new_lobby == null:
		log_msg("Lobby creation failed")
		connection_to_lobby_failed.emit()
		return
	
	# Start listening for P2P
	var result := peer.create_server("testgame")
	if result != OK:
		printerr("Failed to create client: " + EOS.result_str(result))
		connection_to_lobby_failed.emit()
		return
	
	multiplayer.multiplayer_peer = peer
	
	connected_to_lobby.emit(new_lobby, true)
	log_msg("Lobby creation succesful: \n	lobby_id = " + new_lobby.lobby_id)
	
	is_server = true
	local_lobby = new_lobby

func search_lobbies():
	var lobbies = await HLobbies.search_by_bucket_id_async(EosCredentials.PRODUCT_NAME)
	lobby_list_updated.emit(lobbies)
	
func join_lobby(lobby: HLobby) -> bool:
	log_msg("Connecting to lobby...")
	await HLobbies.join_async(lobby)
	
	var result := peer.create_client("testgame", lobby.owner_product_user_id)
	if result != OK:
		connection_to_lobby_failed.emit()
		printerr("Failed to create client: " + EOS.result_str(result))
		return false
	
	local_lobby = lobby
	connected_to_lobby.emit(lobby, false)
	log_msg("Connected to lobby " + lobby.lobby_id)
	
	multiplayer.multiplayer_peer = peer
	
	return true

func join_lobby_by_id(lobby_id: String) -> bool:
	log_msg("Connecting to lobby...")
	var lobby = await HLobbies.join_by_id_async(lobby_id)
	
	if not lobby:
		connection_to_lobby_failed.emit()
		log_msg("Failed to connect to lobby")
		return false
	
	var result := peer.create_client("testgame", lobby.owner_product_user_id)
	if result != OK:
		connection_to_lobby_failed.emit()
		printerr("Failed to create client: " + EOS.result_str(result))
		return false

	local_lobby = lobby
	connected_to_lobby.emit(lobby, false)
	log_msg("Connected to lobby " + lobby.lobby_id)
	
	multiplayer.multiplayer_peer = peer
	
	return true

func leave_current_lobby():
	log_msg("Leaving lobby...")
	var res = await local_lobby.leave_async()
	if res: log_msg("Lobby leaved")
	else: log_msg("Lobby was not left")

func _on_peer_connected(peer_id: int) -> void:
	log_msg("Player %d connected" % peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	log_msg("Player %d disconnected" % peer_id)
