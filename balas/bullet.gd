extends Area2D

var rotate_player 

var dire = Vector2(1,0)
var playim : KinematicBody2D
puppet var puppet_position = Vector2(0,0) setget puppet_position_set
puppet var puppet_dire = dire
puppet var puppet_rotate = rotate_player 


func _ready() -> void:
	visible = false
	yield(get_tree(),"idle_frame")
	if is_network_master():
		dire = dire.rotated(rotate_player)
		rset("puppet_dire",dire)
		rset("puppet_rotate",rotate_player)
		rset("puppet_position",global_position)
		
	else:
		dire = dire.rotated(rotate_player)
		puppet_dire = dire
	visible = true

func _physics_process(delta) -> void:
	if is_network_master():
		global_position += dire*100*delta*3
	else:
		global_position += puppet_dire*100*delta*3
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position
sync func destroy_bullet() -> void:
	queue_free()
func _on_Timer_timeout():
	if is_network_master():
		rpc("destroy_bullet")

func _on_bullet_area_entered(area):
	pass
	#if is_network_master():
		#rpc("destroy_bullet")


func _on_bullet_body_entered(body):
	if body is TileMap:
		if is_network_master():
			rpc("destroy_bullet")
