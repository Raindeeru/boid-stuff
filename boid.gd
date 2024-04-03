extends CharacterBody2D

const SPEED = 200
var direction: Vector2

var vision_range = 200
var protect_range = 100

@export_range (0, 10) var separation_strength: float = 1
@export_range (0, 10) var alignment_strength: float = 1
@export_range (0, 10) var cohesion_strength: float = 1


var screen_size_x = 1152
var screen_size_y = 648
var turn_factor = 100
var margin = 100

func _ready():
	direction.x = randf_range(-1, 1)
	direction.y = randf_range(-1, 1)
	direction = direction.normalized()

func _physics_process(delta):
	position.x = wrapf(position.x, 0, screen_size_x)
	position.y = wrapf(position.y, 0, screen_size_y)
	
	var boids_in_protected_range = get_boids_in_range(protect_range)
	var boids_in_visible_range = get_boids_in_range(vision_range)
	
	if boids_in_protected_range.size() > 0:
		var separate_vector = separation(boids_in_protected_range)
		direction += direction.move_toward(separate_vector, 0.2)
		direction = direction.normalized()
	
	if boids_in_visible_range.size() > 0:
		var align_vector = alignment(boids_in_visible_range) 
		direction += direction.move_toward(align_vector, 0.2)
		direction = direction.normalized()
		
		var cohesion_vector = cohesion(boids_in_visible_range)
		direction += direction.move_toward(cohesion_vector, 0.2)
		direction = direction.normalized()
	
	var turn_vector:Vector2
	
	#if position.x < margin:
		#turn_vector.x += turn_factor
	#if position.x > screen_size_x - margin:
		#turn_vector.x -= turn_factor
	#if position.y < margin:
		#turn_vector.y += turn_factor
	#if position.y > screen_size_y - margin:
		#turn_vector.y -= turn_factor
	#
	#direction += direction.move_toward(turn_vector, 0.2)
	#direction = direction.normalized()
	
	velocity = direction * SPEED
	
	rotation = atan2(direction.y, direction.x)
	move_and_slide()
	

func get_boids_in_range(given_range:float):
	var boids_in_range = []
	for boid in get_parent().get_children():
		if boid == self:
			continue
		if position.distance_to(boid.position) < given_range:
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
