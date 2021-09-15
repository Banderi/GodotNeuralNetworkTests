extends Node2D

onready var draw = $draw
onready var backdraw = $draw/back
onready var backdraw2 = $draw/back2

var time = 0
func _process(delta):
	Profiler.clock_in("frame_total")
	Profiler.profiling["frame_delta"] = delta
	time += delta

	# local updates
	Profiler.clock_in("update_local")
	NN.update_local_randomizations(delta)
	Profiler.clock_out("update_local")

	# gdnative library updates
	Profiler.clock_in("update_gdnative")
	NN.update_nn()
	Profiler.clock_out("update_gdnative")

	# draw
	Profiler.clock_in("draw")
	if time > 0.2:
		time = 0.0
		backdraw.update()
	backdraw2.update()
	draw.update()
	Profiler.clock_in("draw_text")
	Profiler.draw_text()
	Profiler.clock_out("draw_text")
	Profiler.clock_out("draw", false)
	Profiler.clock_flush("draw")

	Profiler.clock_out("frame_total")

func _ready():
	backdraw.onlyfirstlayer = true
	backdraw2.onlyfirstlayer = false
