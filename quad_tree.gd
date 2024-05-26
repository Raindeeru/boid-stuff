extends Node
class_name QuadTree

const MAX_NODE_CAPACITY = 4
const MAX_DEPTH = 5
var quadbox:bounding_box

var boids_in_node = []
var children_nodes = []

var depth:int

class bounding_box:
	var center:Vector2
	var dimensions:Vector2
	var top
	var left
	var bottom
	var right
	
	func _init(_center:Vector2, _dimensions:Vector2):
		center = _center
		dimensions = _dimensions
		
		left = center.x - dimensions.x
		top = center.y - dimensions.y
		bottom = center.y + dimensions.y
		right = center.x + dimensions.x
	
	func containsBoid(pos:Vector2):
		if pos.x < center.x - dimensions.x:
			return false
		elif pos.x > center.x + dimensions.x:
			return false
		elif pos.y < center.y - dimensions.y:
			return false
		elif pos.y > center.y + dimensions.y:
			return false
		else:
			return true 

func _init(center, dimensions, _depth):
	quadbox = bounding_box.new(center, dimensions)
	depth = _depth


func insert(boid):
	#print(boid.position)
	if !contains_point(boid.position):
		return false
	if boids_in_node.size() < MAX_NODE_CAPACITY or depth == MAX_DEPTH:
		#print(node_name)
		boids_in_node.push_back(boid)
		return true
	
	if children_nodes == []:
		subdivide()
	
	for child in children_nodes:
		if child.insert(boid):
			return true
	
	return false

func subdivide():
	#top right
	var bottom_right = QuadTree.new(quadbox.center + quadbox.dimensions/2, quadbox.dimensions/2, depth+1, )
	var bottom_left = QuadTree.new(Vector2(quadbox.center.x - quadbox.dimensions.x/2, quadbox.center.y + quadbox.dimensions.y/2 ), quadbox.dimensions/2, depth+1)
	var top_left = QuadTree.new(quadbox.center - quadbox.dimensions/2, quadbox.dimensions/2, depth+1)
	var top_right = QuadTree.new(Vector2(quadbox.center.x + quadbox.dimensions.x/2, quadbox.center.y - quadbox.dimensions.y/2 ), quadbox.dimensions/2, depth+1,)
	
	children_nodes.push_back(bottom_right)
	children_nodes.push_back(bottom_left)
	children_nodes.push_back(top_left)
	children_nodes.push_back(top_right)

func contains_point(position):
	if position.x > quadbox.left and position.x < quadbox.right and position.y > quadbox.top and position.y < quadbox.bottom:
		return true
	return false

func range_contains_point(boid, center, x, y):
	if boid.x < center.x - x or boid.x > center.x + x:
		return false
	if boid.y < center.y - y or boid.y > center.y + y:
		return false
	return true

func purge():
	children_nodes.clear()
	boids_in_node.clear()

func intersects(center, x, y):
	if quadbox.right < center.x - x or quadbox.left > center.x + x:
		return false
	if quadbox.bottom < center.y - y or quadbox.top > center.y - y:
		return false
	return true

func query(center, x, y):
	var points_in_range = []
	
	if !intersects(center, x, y):
		return points_in_range
	
	for boid in boids_in_node:
		if range_contains_point(boid.position, center, x, y):
			points_in_range.push_back(boid)
	
	if !children_nodes:
		return points_in_range
	
	for child in children_nodes:
		points_in_range.append_array(child.query(center, x, y))
	
	return points_in_range

func draw_bounding_box():
	DebugDraw2D.rect(quadbox.center, quadbox.dimensions*2, Color(1, 1, 1))
	if children_nodes:
		for child in children_nodes:
			child.draw_bounding_box()
