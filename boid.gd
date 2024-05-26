extends CharacterBody2D

@export var SPEED = 200
var direction: Vector2

var vision_range = 200
var protect_range = 100

@export_range (0, 10) var separation_strength: float = 1
@export_range (0, 10) var alignment_strength: float = 1
@export_range (0, 10) var cohesion_strength: float = 1
@export_range (0, 5000) var collision_avoidance_strength: float = 300

@onready var chosen_point = get_node("Sprite2D2")

@onready var point_texture = preload("res://point.png") 
@onready var best_point_texture = preload("res://chosenpoint.png") 

var sprite2d 

var screen_size_x = 1152
var screen_size_y = 648
var collider_steer = Vector2.RIGHT
var margin = 100

var view_points = []
var front_angle = 0.0
var previous_boid_rotation: float = 0

func _ready():
	direction.x = randf_range(-1, 1)
	direction.y = randf_range(-1, 1)
	
	
	direction = Vector2.UP
	direction = direction.normalized()
	
	view_points = get_circle_points_in_view_range(get_circle_points(50), PI/2 + PI/4)
	
	
	#for point in view_points:
		#var bsprite2d = Sprite2D.new() # Create a new Sprite2D.
		#add_child(bsprite2d)
		#bsprite2d.set_texture(point_texture)
		#bsprite2d.position = point*vision_range
	
	var reordered_points = []
	var mid:int = view_points.size()/2
	
	
	for i in mid+1:
		if i == 0:
			reordered_points.append(view_points[i]) 
		else:
			reordered_points.append(view_points[i])
			reordered_points.append(view_points[view_points.size()-i])
	
	view_points = reordered_points
	

func _physics_process(delta):
	position.x = wrapf(position.x, 0, screen_size_x)
	position.y = wrapf(position.y, 0, screen_size_y)
	
	var boids_in_protected_range = get_boids_in_view_range(get_boids_in_range(protect_range), PI/2 + PI/4)
	var boids_in_visible_range = get_boids_in_view_range(get_boids_in_range(vision_range), PI/2 + PI/4)
	
	var boid_rotation = atan2(direction.y, direction.x) - previous_boid_rotation
	
	previous_boid_rotation = atan2(direction.y, direction.x)
	
	for point in view_points.size():
		view_points[point] = rotate_vector(view_points[point], boid_rotation)
	
	if boids_in_protected_range.size() > 0:
		var separate_vector = separation(boids_in_protected_range)
		direction += direction.move_toward(separate_vector, 0.1)
		direction = direction.normalized()
	
	if boids_in_visible_range.size() > 0:
		var align_vector = alignment(boids_in_visible_range) 
		direction += direction.move_toward(align_vector, 0.1)
		direction = direction.normalized()
		
		var cohesion_vector = cohesion(boids_in_visible_range)
		direction += direction.move_toward(cohesion_vector, 0.1)
		direction = direction.normalized()
	
	#for point in view_points.size():
		#var point_rotation = (atan2(view_points[point].y, view_points[point].x))
		#var rotated_x = cos(point_rotation + boid_rotation)
		#var rotated_y = sin(point_rotation + boid_rotation)
		#
		#view_points[point]  = Vector2(rotated_x, rotated_y)
	
	
	
	var space_state = get_world_2d().direct_space_state
	var hit_points = []
	var best_avoid_direction:Vector2
	var best_avoid_length = 0.0
	
	for point in view_points:
		var query = PhysicsRayQueryParameters2D.create(position, position + point*(vision_range))
		var result = space_state.intersect_ray(query)
		if result:
			if (result.position - position).length() > best_avoid_length:
				best_avoid_direction = point
		else:
			best_avoid_direction = point
			break
	#chosen_point.set_global_position(position + best_avoid_direction*vision_range)
	
	direction += direction.move_toward(best_avoid_direction * collision_avoidance_strength, 0.5)
	direction = direction.normalized()
	
	
	velocity = direction * SPEED
	#print(velocity)
	
	rotation = atan2(direction.y, direction.x)
	move_and_slide()
	
	

func get_boids_in_range(given_range:float):
	var boids_in_range = []
	var boids_to_check = QTree.test.query(position, given_range, given_range)
	
	for boid in boids_to_check:
		if boid == self:
			continue
		if position.distance_to(boid.position) < given_range && boid is CharacterBody2D:
			boids_in_range.append(boid)
	return boids_in_range

func separation(boids_nearby):
	var close_dx = 0.0
	var close_dy = 0.0 
	for boid in boids_nearby: 
		var ratio = (position - boid.position).length()/protect_range
		close_dx += (position.x - boid.position.x) / ratio
		close_dy += (position.y - boid.position.y) / ratio
	return Vector2(close_dx, close_dy)*separation_strength

func alignment(boids_nearby):
	var vel_avg = Vector2.ZERO
	for boid in boids_nearby:
		vel_avg += boid.velocity
	vel_avg = vel_avg / boids_nearby.size()
	return (vel_avg-velocity) * alignment_strength

func cohesion(boids_nearby):
	var pos_avg = Vector2.ZERO
	for boid in boids_nearby:
		pos_avg += boid.position
	pos_avg = pos_avg / boids_nearby.size()
	return (pos_avg-position)*cohesion_strength

func get_circle_points(point_num:int):
	var points = []
	var circle_rotate = (2*PI)/point_num
	for i in point_num:
		points.append(Vector2(cos(circle_rotate*i), sin(circle_rotate*i)))
	return points

func get_circle_points_in_view_range(circle_points, view_range):
	var circle_points_in_view_range = []
	for point in circle_points:
		if atan2(point.y, point.x) < view_range and atan2(point.y, point.x) > -view_range:
			circle_points_in_view_range.append(point)
	return circle_points_in_view_range

func get_boids_in_view_range(circle_points, view_range):
	var circle_points_in_view_range = []
	for point in circle_points:
		if atan2(point.position.y, point.position.x) < view_range and atan2(point.position.y, point.position.x) > -view_range:
			circle_points_in_view_range.append(point)
	return circle_points_in_view_range

#func get_best_direction(hit_ray_points):
	#var best_dir:Vector2
	#var furthest_dist = 0
	#for point in hit_ray_points.size():
		#if point == 0:
			#best_dir = hit_ray_points[point]
		#else:
			#if best_dir.length() < hit_ray_points[point].length():
				#furthest_dist = hit_ray_points[point].length()
				#best_dir = hit_ray_points[point]
	#return best_dir

func rotate_vector(vector:Vector2, angle):
	var new_vector: Vector2
	var vector_angle = atan2(vector.y, vector.x)
	
	new_vector.x = cos(vector_angle + angle)
	new_vector.y = sin(vector_angle + angle)
	
	return new_vector
