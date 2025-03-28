extends KinematicBody2D

var MOVE = Vector2()
var dire = Vector2.ZERO
var hp = 3
var id_player = 0
puppet var id_player_pt = 0

var bala = load("res://balas/bullet.tscn")
var score = 0
var cusangue = true

puppet var puppet_position = Vector2(0,0) setget puppet_possitin_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0
puppet var puppet_name = Network.current_player_username
onready var tween = $Tween
onready var sprite = $Node2D/Sprite
var escala = Vector2(1,1)
var textu
puppet var puppet_sprite : PoolByteArray
puppet var puppet_scale = Vector2(1,1)
puppet var puppet_ani = 0

onready var ani = $Node2D/AnimationPlayer
onready var arma = $arma
onready var poin = $arma/Position2D
onready var t_shoter = $Timer_shoter
onready var hud = $CanvasLayer
onready var time_hit = $hit_time

var s_data : PoolByteArray
var dedo 

func _ready():
	yield(get_tree(), "idle_frame")
	if is_network_master():
		var s = sprite.texture.get_data()
		rset("puppet_scale",sprite.scale)
		s_data = s.save_png_to_buffer()
		puppet_sprite = s_data 
		rset("puppet_sprite",s_data)
	
var temp = 0

func _physics_process(delta):
	#set_multiplayer_authority()
	
	if is_network_master():
		rset("id_player_pt",id_player)
		if get_tree().get_network_connected_peers().size() != temp:
			var s = sprite.texture.get_data()
			rset("puppet_scale",sprite.scale)
			s_data = s.save_png_to_buffer()
			puppet_sprite = s_data 
			rset("puppet_sprite",s_data)
			temp = get_tree().get_network_connected_peers().size()
		hud.show()
		
		$Label.text = Network.current_player_username
		$Camera2D.current = true
		var x_inpunt =  int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
		var y_inpunt = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
		MOVE = Vector2(x_inpunt,y_inpunt)
		if MOVE == Vector2(0,0):
			rset("puppet_ani",0)
			ani.play("parado")
		else:
			ani.play("andar")
			rset("puppet_ani",1)
		if cusangue:
			if Input.is_action_pressed("ui_shotter") or Input.is_action_just_pressed("ui_shotter"):
				rpc("shote", get_tree().get_network_unique_id())
				cusangue = false
				t_shoter.start()
		
		arma.look_at(get_global_mouse_position())
		
	else:
		id_player = id_player_pt
		hud.hide()
		
		if puppet_ani == 0:
			ani.play("parado")
		if puppet_ani == 1:
			ani.play("andar")
		
		if puppet_sprite != s_data:
			
			var img = Image.new()
			var err = img.load_png_from_buffer(puppet_sprite)  # Carrega a imagem dos bytes recebidos
			if err == OK:
				var tex = ImageTexture.new()
				tex.create_from_image(img)  # Cria uma textura a partir da imagem
				sprite.scale = puppet_scale
				tex.set_flags(Texture.FLAG_FILTER) 
				tex.set_flags(Texture.FLAG_MIPMAPS)
				sprite.texture = tex  # Aplica a textura no Sprite
			puppet_sprite = s_data 
		
		$Camera2D.current = false
		arma.rotation_degrees = lerp(arma.rotation_degrees,puppet_rotation,delta*10)
		$Label.text = puppet_name
		
	$CanvasLayer/Control/Label2.text = "vida: " + str(hp)
	$CanvasLayer/Control/Label3.text = "pontos: " + str(Global.pontos[id_player])
	move_and_slide(MOVE*100)
	if hp <= 0:
		if get_tree().is_network_server():
			rpc("destroy")

sync func destroy():
	hp = 3
	global_position = Vector2(130,130)

func puppet_possitin_set(new_value):
	puppet_position = new_value
	tween.interpolate_property(self,"global_position",global_position,puppet_position, 0.1)
	tween.start()

sync func shote(id):
	var d = Global.instance_node_at_location(bala,get_parent(),poin.global_position)
	d.playim = self
	d.rotate_player = arma.rotation
	d.name = "bala" + name + str(Network.network_obj_name_index) 
	d.set_network_master(id)
	Network.network_obj_name_index += 1

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position",global_position)
		rset_unreliable("puppet_velocity",MOVE)
		rset_unreliable("puppet_rotation",arma.rotation_degrees)
		rset_unreliable("puppet_name",Network.current_player_username)

func _on_Timer_shoter_timeout():
	if is_network_master():
		cusangue = true

func _on_hit_time_timeout():
	modulate = Color(1,1.0,1.0,1)
	
sync func _hit_to_damege(dam):
	hp -= dam
	modulate = Color(1,0.8,0.8,0.9)
	time_hit.start()

func _on_hit_box_body_entered(_body) -> void:
	if get_tree().is_network_server():
		rpc("_hit_to_damege",1)
