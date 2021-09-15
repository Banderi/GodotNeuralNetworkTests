extends Node2D

onready var draw = $draw
onready var backdraw = $draw/back
onready var backdraw2 = $draw/back2

var time = 0
var time2 = 0
func _process(delta):
	Profiler.clock_in("frame_total")
	Profiler.profiling["frame_delta"] = delta
	time += delta
	time2 += delta

	Profiler.clock_in("update_local")

	# randomize weights
	if time > 1.0:
		time = 0.0
		Profiler.clock_in("rand_weights_local")
		NN.randomize_neuron_weights(0, false)
		NN.randomize_neuron_weights(1, true, -4000, -500)
		NN.randomize_neuron_weights(2, true, -2000, -500)
		NN.randomize_neuron_weights(3, true, -2000, -500)
		Profiler.clock_out("rand_weights_local")

	# randomize inputs
	Profiler.clock_in("rand_activ_local")
	NN.randomize_neuron_inputs()
	Profiler.clock_out("rand_activ_local")

	# update neural network
	Profiler.clock_in("update_gdnative")
	NN.update_nn()
	Profiler.clock_out("update_gdnative")

	Profiler.clock_out("update_local")

	# draw
	Profiler.clock_in("draw")
	if time2 > 0.2:
		time2 = 0.0
		backdraw.update()
	backdraw2.update()
	draw.update()
	Profiler.clock_in("draw_text")
	Profiler.draw_text()
	Profiler.clock_out("draw_text")
	Profiler.clock_out("draw", false)
	Profiler.clock_flush("draw")

	# consolidate some profiling times...
#	Profiler.profiling["draw"] = Profiler.profiling["draw_text"]
#	Profiler.profiling["draw"] += Profiler.profiling["draw_text"]
#	Profiler.profiling["draw"] += Profiler.profiling["draw_synapses_first"]
#	Profiler.profiling["draw"] += Profiler.profiling["draw_synapses_second"]
#	Profiler.profiling_temp["draw"][1] = Profiler.profiling["draw"]
#	Profiler.clock_flush("draw")

#	# fps
#	Profiler.profiling_temp["fps"][1] = Performance.get_monitor(0)
#	Profiler.clock_flush("fps")

#	# SPECIAL
#	Profiler.profiling_temp["profiling"][1] = Profiler.profiling["profiling"]
#	Profiler.clock_flush("profiling")

	Profiler.clock_out("frame_total")

func _ready():
	backdraw.onlyfirstlayer = true
	backdraw2.onlyfirstlayer = false
