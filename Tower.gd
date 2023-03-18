extends KinematicBody

#used as a state varible that updates wether it is being dragged or not
var x = false
export var GroundPath: NodePath
onready var Ground = get_node(GroundPath)

export var DesignatedAreaPath: NodePath
onready var DesignatedArea = get_node(DesignatedAreaPath)
var curArea = null

var canPlace = false
var towerIsPlaced = false

var towerRaycast = null
var currentTarget = null
var enemies = []
var enemiesInRange = 0




func _ready():
	# Don't detect collisions with the turret itself
	towerRaycast = $GunBarrel/RayCast
	towerRaycast.add_exception(self)
	towerRaycast.enabled = false

	# Add all enemies to the enemies array
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemies.append(enemy)

#these functions execute when the signal is sent from main
func on_Drag():
	x = true
	towerIsPlaced = false

func on_Stop_Drag():
	x = false
	if canPlace:
		translation = Vector3(curArea.translation.x, 3, curArea.translation.z)
		towerIsPlaced = true
		
		# If there is an enemy in range, lock onto the closest one
		if enemiesInRange > 0:
			LockOnClosestEnemy()
	else:
		towerIsPlaced = false
	
#updates tower translation to go with mouse
func _process(fl):
	if x == true:
		var newPos = ScreenPointToRay()
		self.translation = Vector3(newPos.x, 3, newPos.z)
		
	# Check if there is a current target and the raycast is enabled
	if currentTarget and towerRaycast.enabled:
		# Check if the raycast intersects the current target
		var raycastCollider = towerRaycast.get_collider()
		
		if (raycastCollider) and (raycastCollider == currentTarget):
			# Shoot at enemy
			print("shooting enemy")
			pass
			
		else:
			# The target is no longer in range, disable the raycast and clear the current target
			towerRaycast.enabled = false
			currentTarget = null
			print("stopped shooting at enemy")

	
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


func _on_TowerRange_body_entered(body):
	# Enable the raycast and set its position and target to the barrel
	if body in enemies:
		print("enemy detected!")
		currentTarget = body
		LockOnClosestEnemy()
		enemiesInRange += 1


func _on_TowerRange_body_exited(body):
	# Disable the raycast and clear the current target
	if body == currentTarget:
		print("enemy not in range anymore!")
		towerRaycast.enabled = false
		currentTarget = null
		enemiesInRange -= 1


func LockOnClosestEnemy():
	# Only lock on if the tower has been placed
	if towerIsPlaced == false:
		print("tower hasn't been placed")
		return
	print("tower placed")
	# Get the closest enemy within range
	var closestEnemy = null
	var closestDistance = 9999999 # Set a large initial value

	for enemy in enemies:
		var distance = (enemy.global_transform.origin - self.global_transform.origin).length()
		if distance < closestDistance:
			closestDistance = distance
			closestEnemy = enemy
	
	# Check if tower can lock onto the closest enemy
	if closestEnemy:
		print("Enemies in Range: ", enemiesInRange)
		print("locking onto enemy!")
		
		# Get the direction towards the enemy
		var direction = (closestEnemy.global_transform.origin - self.global_transform.origin).normalized()

		# Calculate the rotation towards the enemy
		var up = Vector3.UP
		var right = direction.cross(up).normalized()
		up = right.cross(direction).normalized()
		var targetRotation = Basis(right, up, direction)

		# Set the rotation of the tower towards the enemy
		self.global_transform.basis = targetRotation
		
		# Enable the raycast and set its position and target to the barrel
		towerRaycast.enabled = true
		towerRaycast.global_transform.origin = $GunBarrel.global_transform.origin
		towerRaycast.look_at(closestEnemy.global_transform.origin, Vector3(0, 1, 0))
		
	else:
		# No enemies within range, disable the raycast and clear the current target
		print("no enemies in range!")
		towerRaycast.enabled = false
		currentTarget = null
