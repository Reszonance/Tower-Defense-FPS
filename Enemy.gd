extends KinematicBody

#used as a state varible that updates wether it is being dragged or not
var x = false
var Ground 

signal thisCanBeDragged
signal StopDragging

var curArea = null

var towerIsPlaced = false
var canPlace = false


func _ready():
	var cameraMain = get_node("../CameraPivot/Camera")
	connect("thisCanBeDragged", cameraMain, "addToDrag", [self])
	emit_signal("thisCanBeDragged")
	connect("StopDragging", cameraMain, "drop")
	Ground = get_node("../Ground")
	
#these functions execute when the signal is sent from main
func on_Drag():
	print("hihihihi")
	x = true

func on_Stop_Drag():
	emit_signal("StopDragging")
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


