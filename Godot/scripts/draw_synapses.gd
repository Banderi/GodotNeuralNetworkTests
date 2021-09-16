extends Node2D

var onlyfirstlayer = false

var o_x = 320
var o_y = 280

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

	var col = Color(0.5, 0.5, 0, 1)
	if weight < 0:
		col = col.linear_interpolate(Color(0,0,1,1), 1 - weight)
	if weight > 0:
		col = col.linear_interpolate(Color(1,0,0,1), weight)
	col *= min(1.0, max(0.5, activation))
	col.a = 1.0

	draw_line(pos + Vector2(3, 3), pos2 + Vector2(3, 3), col)

func _draw():
	# draw synapses
	Profiler.clock_in("draw")
	if onlyfirstlayer:
		Profiler.clock_in("draw_synapses_first")
	else:
		Profiler.clock_in("draw_synapses_second")

	var l_min = 0
	var l_max = 1
	if !onlyfirstlayer:
		l_min = 1
		l_max = NN.data.size()

	for l in range(l_min, l_max):
		# get layer data array
		var layer = NN.data[l]

		# iterate over every neuron
		for n in range(layer.size()):

			# get neuron object
			var neuron = layer[n]
			var total_synapses = neuron[2].size()

			var pos = get_pos(l, n, layer.size())
			if total_synapses > 0: #&& l > 0

				# not quite for EVERY neuron..?
				var sampled = true
				if onlyfirstlayer:
					sampled = false
					var det = 2
#					if n % det == 0 && (n / 64) % det == 0:
#						sampled = true
#					if n % 64 == 63 && (n % det == 0 || (n / 64) == 0):
#						sampled = true
					if (n / 64) % 64 == 63 && (n % det == 0 || n % 64 == 0):
						sampled = true

				if l > 0 || sampled:
					for w in total_synapses: # max 20..?
						draw_synapse(pos, l, n, w, total_synapses)

	if onlyfirstlayer:
		Profiler.clock_out("draw_synapses_first")
	else:
		Profiler.clock_out("draw_synapses_second")
	Profiler.clock_out("draw", false)
