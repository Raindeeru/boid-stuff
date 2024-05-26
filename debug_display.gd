extends Label

var fps
var objects

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps = Performance.get_monitor(Performance.TIME_FPS)
	objects = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	text = str(fps) + " fps \n" + str(objects) + " objects"
