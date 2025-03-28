extends Control

var player = load("res://players/playerA.tscn")

onready var multiplay_config_ui = $background_panel
onready var server_ip_address = $background_panel/server_ip_address
onready var username = $background_panel/username
onready var device_ip_address = $CanvasLayer/device_ip_address

onready var start_game = $CanvasLayer/strat_game

var player_img : ImageTexture

func _ready():
	$background_panel/FileDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	$background_panel/username.grab_focus()
	get_tree().connect("network_peer_connected", self,"_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self,"_connected_to_server")
	
	device_ip_address.text = Network.ip_address 
	if get_tree().network_peer != null:
		pass
	else:
		start_game.hide()
func _process(_delta):
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 0 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()

func _on_Create_server_pressed():
	#if username.text != "":
	Network.current_player_username = username.text
	multiplay_config_ui.hide()
	Network.create_server()
	set_network_master(get_tree().get_network_unique_id())
	#	Global.id_adm = get_tree().get_network_unique_id() 
		#instance_player(get_tree().get_network_unique_id())
func _player_connected(id) -> void:
	print(id)
	print("Player"+ str(id) + " has connected")
	print(11221212)
	instance_player(id)
	
	
func _player_disconnected(id) -> void:
	print("Player"+ str(id) + " has disconnected")
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()

func _on_Join_server_pressed():
	if server_ip_address.text != "" and username.text != "":
		Network.current_player_username = username.text
		multiplay_config_ui.hide()
		Network.ip_address = server_ip_address.text
		Network.join_server()

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())
	if Players.has_node(str(1)):
		Players.get_node(str(1)).queue_free()
	
func instance_player(id) -> void:
	var player_instace = Global.instance_node_at_location(player,Players,Vector2(512/2,288/2))
	player_instace.name = str(id)
	player_instace.id_player = Global.pontos.size() - 1
	Global.pontos.append(0)
	print(Global.pontos)
	if player_img != null:
		print("ai calica")
		player_instace.sprite.texture = player_img
		player_instace.textu = player_img
		var tam_img = player_img.get_size()
		player_instace.escala = Vector2(20/tam_img.x,22/tam_img.y)
		player_instace.sprite.scale = Vector2(20/tam_img.x,22/tam_img.y)
	player_instace.set_network_master(id)

func _on_strat_game_pressed():
	rpc("swicht_to_game")
	
sync func swicht_to_game() -> void:
	get_tree().change_scene("res://layer/game/game.tscn")

func _on_img_b_pressed():
	$background_panel/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	var img = Image.new()
	img.load(path)
	
	var text_img = ImageTexture.new()
	text_img.create_from_image(img)
	text_img.set_flags(Texture.FLAG_FILTER) 
	text_img.set_flags(Texture.FLAG_MIPMAPS)
	var tam_img = text_img.get_size()
	$background_panel/Sprite.scale = Vector2(20/tam_img.x,20/tam_img.y) 
	$background_panel/Sprite.texture = text_img
	player_img = text_img
	
