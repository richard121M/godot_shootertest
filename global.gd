extends Node

var id_adm = 0

func instance_node_at_location(node:Object, parent: Object, location: Vector2) -> Object:
	var node_instace = instance_node(node,parent)
	node_instace.global_position = location
	return node_instace

func instance_node(node: Object, parent: Object) -> Object:
	var node_instace = node.instance()
	parent.add_child(node_instace)
	return node_instace
