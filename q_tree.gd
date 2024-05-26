extends Node

var boid_positions = []

var test:QuadTree

# Called when the node enters the scene tree for the first time.
func _ready():
	test = QuadTree.new(get_viewport().size / 2.0, get_viewport().size/2, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
