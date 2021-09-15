extends Node2D

var o_x = 300
var o_y = 300

func get_pos(layer, index, max_index):

	var info = NN.config[layer]

	var row = index % info["max_row"]
	var column = index / info["max_row"]
	var x = o_x + info["x"] + (column * info["column_spacing"])
	var y = o_y + (row * info["row_spacing"]) - (min(max_index, info["max_row"]) * info["row_spacing"] * 0.5)
	return Vector2(x, y)

#####

func draw_synapse(pos, l, n, w, total_synapses):
	var pos2 = get_pos(l + 1, w, total_synapses)
	var activation = NN.data[l][n][0]
	var weight = NN.data[l][n][2][w]
	draw_line(pos + Vector2(3, 3), pos2 + Vector2(3, 3), Color(0,0,0,1).linear_interpolate(Color(1,0,0,1), activation * weight))

func _draw():

	Profiler.clock_in("draw")

	# draw graphics
	for l in range(NN.data.size()):
		# get layer data array
		var layer = NN.data[l]

		# get next (destination) layer data array
#		var next_l = null
#		if l_index + 1 < NN.data.size():
#			next_l = NN.data[l_index + 1]

		# iterate over every neuron
		for n in range(layer.size()):

			# get neuron object
			var neuron = layer[n]

			var total_synapses = neuron[2].size()

			# draw synapses
			var pos = get_pos(l, n, layer.size())
			if l > 0 && total_synapses > 0: # && synapses
				Profiler.clock_in("draw_synapses")
				for w in total_synapses:
					draw_synapse(pos, l, n, w, total_synapses)
#				for w_index in next_l.size():
#					if n_index > layer.size() - NN.config[l_index]["max_row"]:
#						var w = 0.0
#						if w_index < n[2].size():
#							w = n[2][w_index]
#						var pos2 = get_pos(l_index + 1, w_index, next_l.size())
#						below.draw_line(pos + Vector2(3, 3), pos2 + Vector2(3, 3), Color(0,0,0,1).linear_interpolate(Color(1,0,0,1), w))
				Profiler.clock_out("draw_synapses", false)

			# draw neuron
			Profiler.clock_in("draw_neurons")
			draw_rect(Rect2(pos.x, pos.y, 6, 6), Color(0,0,0,1).linear_interpolate(Color(1,1,1,1), neuron[0]))
			Profiler.clock_out("draw_neurons", false)

	# flush profiler temp fields...
	Profiler.clock_flush("draw_neurons")
	Profiler.clock_flush("draw_synapses")

	Profiler.clock_out("draw")

func _ready():
	Profiler.label = $Label
