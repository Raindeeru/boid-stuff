extends Node2D

var boid_amount = 100
var boid = preload("res://boid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in boid_amount:
		var new_boid = boid.instantiate()
		add_child(new_boid)
		new_boid.position.x = randf_range(0,1000)
		new_boid.position.y = randf_range(0,600)
