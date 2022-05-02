extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time = 0
var count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.name + " ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	time += delta
	if time > 5:
		count += 1
		print(self.name + " call " + str(count))
		time = 0
