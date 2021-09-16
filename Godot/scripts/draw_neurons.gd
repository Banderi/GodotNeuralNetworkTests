extends Node2D

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

func _draw():
	Profiler.clock_in("draw_neurons")
	Profiler.clock_in("draw")

	# draw graphics
	for l in range(NN.data.size()):
		# get layer data array
		var layer = NN.data[l]

		# iterate over every neuron
		for n in range(layer.size()):

			# get neuron object
			var neuron = layer[n]

			# draw neuron
			var pos = get_pos(l, n, layer.size())
			var opacity = 1
			if l > 0:


				var col = Color(0.5, 0.5, 0, 1)
				if neuron[1] < 0:
					col = col.linear_interpolate(Color(0,0,1,1), abs(neuron[1]))
				if neuron[1] > 0:
					col = col.linear_interpolate(Color(1,0,0,1), neuron[1])
#				col *= min(1.0, activation)
#				col.a = 1.0

				if neuron.size() > 3:
					draw_rect(Rect2(pos.x - 1 + 6, pos.y - 1, 3, 7), Color(0,0,0,opacity).linear_interpolate(Color(1,1,1,opacity), neuron[3]))



				draw_rect(Rect2(pos.x - 1, pos.y - 1, 7, 7), col)
			draw_rect(Rect2(pos.x, pos.y, 5, 5), Color(0,0,0,opacity).linear_interpolate(Color(1,1,1,opacity), neuron[0]))


	Profiler.clock_out("draw", false)
	Profiler.clock_out("draw_neurons")
