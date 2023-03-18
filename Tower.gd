extends KinematicBody

#used as a state varible that updates wether it is being dragged or not
var x = false
var Ground

signal thisCanBeDragged
signal StopDragging

var curArea = null

var canPlace = false
var towerIsPlaced = true

var towerRaycast = null
var currentTarget = null
var enemies = []
var enemiesInRange = []

var curDist = 9999999
var minDist = float("1e5")
var enemyToTarget = null




func _ready():
	
	var cameraMain = get_node("../CameraPivot/Camera")
	connect("thisCanBeDragged", cameraMain, "addToDrag", [self])
	emit_signal("thisCanBeDragged")
	connect("StopDragging", cameraMain, "drop")
	
	Ground = get_node("../Ground")
	
	
	
	
	
	# Don't detect collisions with the turret itself
	towerRaycast = $GunBarrel/RayCast
	towerRaycast.add_exception(self)
	towerRaycast.enabled = false
	
	

	# Add all enemies to the enemies array
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemies.append(enemy)

#these functions execute when the signal is sent from main
func on_Drag():
	canPlace = true
	print("its working")
	x = true
	towerIsPlaced = false
	$Area/MeshInstance.visible = true

func on_Stop_Drag():
	if canPlace:
		emit_signal("StopDragging")
		
		towerIsPlaced = true
		x = false
		$Area/MeshInstance.visible = false
		
		# If there is an enemy in range, lock onto the closest one
		#if enemiesInRange > 0:
		#	LockOnClosestEnemy()
	else:
		towerIsPlaced = false
		
	
#updates tower translation to go with mouse
func _process(fl):
	if x == true:
		
		var newPos = ScreenPointToRay()
		self.translation = Vector3(newPos.x, 3, newPos.z)
		
	
	# Check if there is a current target and the raycast is enabled
	if enemiesInRange.size() > 0 && towerIsPlaced:
		
		if currentTarget:
			var direction = (currentTarget.global_transform.origin - self.global_transform.origin).normalized()
			look_at(currentTarget.translation, Vector3(0, 1, 0))
			
			
		else:
			print("searching for new target")
			for i in enemiesInRange:
				curDist = EuclideanDist(self.translation, i.translation)
				if curDist < minDist:
					minDist = curDist
					enemyToTarget = i
			currentTarget = enemyToTarget
			
			
		
		towerRaycast.enabled = true
		# Check if the raycast intersects the current target
		#var raycastCollider = towerRaycast.get_collider()
		#LockOnClosestEnemy()
	else:
		towerRaycast.enabled = false
		currentTarget = null
	

	
func EuclideanDist(p1: Vector3, p2: Vector3):
	var x = (p2.x - p1.x)*(p2.x - p1.x)
	var y = (p2.y - p1.y)*(p2.y - p1.y)
	var z = (p2.z - p1.z)*(p2.z - p1.z)
	return sqrt(x+y+z)
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
	print(area)
	canPlace = false
		


func _on_Area_area_exited(area):
	print(area)
	canPlace = true


func _on_TowerRange_body_entered(body):
	# Enable the raycast and set its position and target to the barrel
	if body in enemies:
		print("enemy detected!")
		
		#currentTarget = body
		enemiesInRange.append(body)
		print(enemiesInRange)


func _on_TowerRange_body_exited(body):
	# Disable the raycast and clear the current target
	if body == currentTarget:
		print("enemy not in range anymore!")
		#towerRaycast.enabled = false
		enemiesInRange.erase(body)
		currentTarget = null
		minDist = 999999
		
		
		
	if body in enemies:
		print("an enemy left tower range")
		enemiesInRange.erase(body)
		
	
	


