extends Node2D

onready var draw = $draw

var time = 0
func _process(delta):
	Profiler.clock_in("frame_total")
	Profiler.profiling["frame_delta"] = delta
	time += delta

	# randomize weights
	if time > 1.0:
		time -= 1.0
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
#	Profiler.clock_in("update_nn_local")
#	NN.update_neurons()
#	Profiler.clock_out("update_nn_local")

	Profiler.clock_in("update_gdnative")
	NN.update_nn()
	Profiler.clock_out("update_gdnative")

	# draw
#	if time > 1.0:
#		time -= 1.0
#		draw.draw_synapses()
	draw.update()
	Profiler.clock_in("draw_text")
	Profiler.draw_text()
	Profiler.clock_out("draw_text")

	Profiler.clock_out("frame_total")
