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
				draw_rect(Rect2(pos.x - 1, pos.y - 1, 7, 7), Color(1,1,1,0.5))
			draw_rect(Rect2(pos.x, pos.y, 5, 5), Color(0,0,0,opacity).linear_interpolate(Color(1,1,1,opacity), neuron[0]))


	Profiler.clock_out("draw", false)
	Profiler.clock_out("draw_neurons")
