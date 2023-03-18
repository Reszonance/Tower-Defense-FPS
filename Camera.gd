extends Camera

#signals sent to the "towers" to set their state 
signal DraggingObject
signal StopDragging

#externally set varible to determine what qualifies as a "tower# within the script
#TODO: change to an array of var so that multiple instances can be set as towers
export var tower: NodePath

var Draggable = []

#boolean used to see if the next left click is used to drag or drop the object the mouse is currently hovering over
var isDragging = false

#position of the mouse relative to viewport
var mouse = Vector2()

#a pointer to the object currently being dragged
var objectDragged = null

func _input(event):
	#if the mouse is moved
	if event is InputEventMouse:
		# then update the pos of the mouse
		mouse = event.position
	#if they left click
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			
			#if nothing is currently being dragged
			if !isDragging:
				#then get the thing being clicked on (if anything)
				get_selection()
				
			else:
				connect("StopDragging", objectDragged, "on_Stop_Drag")
				emit_signal("StopDragging")
				disconnect("StopDragging", objectDragged, "on_Stop_Drag")
				#otherwise drop the current object
				#drop()
				#isDragging = false
	
#function that shoots a ray from the mouse position into the depths of the viewport and stops at the first thing it intersects with
func get_selection():
	
	#defines the rays
	var worldspace = get_world().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	
	#the result after all the ray math is a dict containing the info of the thing it collides with
	# will be empty if nothing collided with it
	var result = worldspace.intersect_ray(start, end)
	var collider = result.get("collider")
	#if the collider is a tower
	#TODO: change this to work with an array
	if collider in Draggable:
		
		print("hi")
		#then start dragging the object relative to mouse pos
		isDragging = true
		connect("DraggingObject", collider, "on_Drag")
		objectDragged = collider
		emit_signal("DraggingObject")
		
	
#function made for dropping the currently dragged object
func drop():
	
	#connect("StopDragging", objectDragged, "on_Stop_Drag")
	#emit_signal("StopDragging")
	disconnect("DraggingObject", objectDragged, "on_Drag")
	
	isDragging = false
	
func addToDrag(obj):
	print(obj)
	Draggable.append(obj)
