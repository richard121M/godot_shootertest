extends KinematicBody2D

var move = Vector2(0,0)
var pos_player = Vector2(0,0)
var list_players = []
var live = 3

var ani = 0
var random = RandomNumberGenerator.new()

puppet var puppet_ani = ani
puppet var puppet_live = live
puppet var puppet_move = move
puppet var puppet_posPlayer = pos_player
puppet var puppet_pos = global_position

onready var text_live = $Label

var one_sote = true
func _ready():
	random.randomize()
	if is_network_master():
		set_network_master(get_tree().get_network_unique_id())


func _physics_process(delta):
	if is_network_master():
		var dist = Vector2(0,0)
		for players in list_players:
			if dist != Vector2(0,0):
				if global_position.distance_to(players.global_position) < global_position.distance_to(dist):
					dist = players.global_position
			else:
				dist = players.global_position
			puppet_posPlayer = dist
			pos_player = puppet_posPlayer
			
		if list_players.size() > 0:
			move = lerp(move,global_position.direction_to(pos_player)*90,0.06)
			
			move_and_slide(move)
			rset("puppet_posPlayer",pos_player)
			ani = 1
			$Sprite/AnimationPlayer.play("idol")
			one_sote = true
		else:
			
			if one_sote:
				pos_player = _random_pos()
				one_sote = false
			ani = 0
			$Sprite/AnimationPlayer.play("parou")
			move = lerp(move,global_position.direction_to(pos_player)*90,0.06)
			move_and_slide(move)
			rset("puppet_posPlayer",pos_player)
		rset("puppet_ani",ani)
		rset_unreliable("puppet_pos",global_position)
		if live < 3:
			text_live.show()
			text_live.text = str(live)
		else:
			text_live.hide()
	else:
		if puppet_ani == 0:
			$Sprite/AnimationPlayer.play("parou")
		if puppet_ani == 1:
			$Sprite/AnimationPlayer.play("idol")
		
		global_position = puppet_pos
		if puppet_live < 3:
			text_live.show()
			text_live.text = str(puppet_live)
		else:
			text_live.hide()
		
func _on_Area2D_body_entered(body):
	if body in list_players:
		pass
	else:
		list_players.append(body)
	
func _on_Area2D_body_exited(body):
	if body in list_players:
		list_players.erase(body)

sync func destroy():
	queue_free()

func _random_pos():
	var x_ = random.randi_range(-20,20)
	var y_ = random.randi_range(-20,20)
	var pos_m = Vector2(x_*16,y_*16)+global_position
	return pos_m
func _on_area_hit_area_entered(area):
	
	live -= 1
	move = Vector2(global_position.direction_to(area.global_position)*-220)
	rset("puppet_live",live)
	if live <= 0 or puppet_live <= 0:
		area.playim._score_add(1)
		rpc("destroy")
	area.rpc("destroy_bullet")
	
