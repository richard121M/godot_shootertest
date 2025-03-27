extends Sprite

var zombie = load("res://zombie/zombie.tscn")
var random = RandomNumberGenerator.new()
func _ready():
	random.randomize()

func _on_Timer_timeout():
	if is_network_master():
		rpc("_spawn_zombies")

sync func _spawn_zombies():
	var _x = random.randi_range(-15,15)
	var _y = random.randi_range(-15,15)
	var z = Global.instance_node_at_location(zombie,get_parent(),global_position+Vector2(_x,_y))
	
