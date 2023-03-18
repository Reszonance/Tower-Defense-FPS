extends KinematicBody

#used as a state varible that updates wether it is being dragged or not
var x = false
export var GroundPath: NodePath
onready var Ground = get_node(GroundPath)

export var DesignatedAreaPath: NodePath
onready var DesignatedArea = get_node(DesignatedAreaPath)
var curArea = null

var canPlace = false

#these functions execute when the signal is sent from main
func on_Drag():
	x = true

func on_Stop_Drag():
	
	x = false
	if canPlace:
		translation = Vector3(curArea.translation.x, 3, curArea.translation.z)
	
#updates tower translation to go with mouse
func _process(fl):
	if x == true:
		var newPos = ScreenPointToRay()
		self.translation = Vector3(newPos.x, 3, newPos.z) 
	
	
#function used to get the mouse position in 3d
func ScreenPointToRay():
	
	#just more rays
	var spaceState = get_world().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera()
	var rayOrigin = camera.project_ray_origin(mouse_pos)
	var rayEnd = rayOrigin + camera.project_ray_normal(mouse_pos) * 2000
	
	
	var rayArray = spaceState.intersect_ray(rayOrigin, rayEnd)
	if rayArray.get("collider") == Ground:
		return rayArray["position"]
	else:
		return self.translation



func _on_Area_area_entered(area):
	if area == DesignatedArea:
		canPlace = true
		curArea = area


func _on_Area_area_exited(area):
	if area == DesignatedArea:
		canPlace = false
