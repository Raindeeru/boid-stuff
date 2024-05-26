extends Node2D

var boid_amount = 100
var boid = preload("res://boid.tscn")

var range_dimensions = Vector2(500, 300)
var range_center:Vector2
var range_boids

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	for i in boid_amount:
		var new_boid = boid.instantiate()
		add_child(new_boid)
		new_boid.position.x = randf_range(0, 1000)
		new_boid.position.y = randf_range(0, 500)
		
		QTree.boid_positions.append(new_boid)
		
		#new_boid.position.x = 500
		#new_boid.position.y = 300
	for boid in QTree.boid_positions:
		QTree.test.insert(boid)
	
func _process(delta):
	QTree.test.purge()
	var screen_center = get_viewport().size / 2.0
	for boid in QTree.boid_positions:
		QTree.test.insert(boid)
	DebugDraw2D.rect(range_center, range_dimensions, Color(1, 1, 0))
	range_boids = QTree.test.query(range_center, range_dimensions.x/2, range_dimensions.y/2)
	QTree.test.draw_bounding_box()
	

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		#range_center = event.position
		QTree.test.print_all_nodes()
