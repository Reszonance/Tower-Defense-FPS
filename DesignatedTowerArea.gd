extends Area

export var TowerPath: NodePath
onready var Tower = get_node(TowerPath)
var canPlace = false



func _on_DesignatedTowerArea_body_entered(body):
	if body == Tower:
		canPlace  = true
	print(canPlace)


func _on_DesignatedTowerArea_body_exited(body):
	if body == Tower:
		canPlace  = false
	print(canPlace)
