#tool
extends Node2D

var data = [
]
var config = [
	{
		"size": 64*64,
		"max_row": 64,
		"x": 0,
		"row_spacing": 5,
		"column_spacing": 5
	},
	{
		"size": 40,
		"max_row": 20,
		"x": 400,
		"row_spacing": 10,
		"column_spacing": 10
	},
	{
		"size": 20,
		"max_row": 20,
		"x": 450,
		"row_spacing": 10,
		"column_spacing": 10
	},
	{
		"size": 10,
		"max_row": 20,
		"x": 500,
		"row_spacing": 10,
		"column_spacing": 10
	}
]

var o_x = 300
var o_y = 300

onready var label = $label

func get_pos(layer, index, max_index):

	var info = config[layer]

	var row = index % info["max_row"]
	var column = index / info["max_row"]
	var x = o_x + info["x"] + (column * info["column_spacing"])
	var y = o_y + (row * info["row_spacing"]) - (min(max_index, info["max_row"]) * info["row_spacing"] * 0.5)
	return Vector2(x, y)



### TEST!!!
onready var TESTLIB = preload("res://bin/test.gdns").new()

#####

func check_init_data_array_sizes():

	# first, add layers as needed if any is missing
	while data.size() < config.size():
		data.push_back([])

	for layer_i in config.size():
		var layer_info = config[layer_i]
		var layer = data[layer_i]

		# secondly, add neurons as needed if any is missing
		while layer.size() < layer_info["size"]:
			layer.push_back([0.0, 0.0, []])

func randomize_neuron_inputs():
	for n in data[0]:
		n[0] = rand_range(0.0, 1.0)
func randomize_neuron_weights(layer, randomize_bias, bias_min = 0, bias_max = 0):

	# get next (destination) layer data array
	var next_layer_size = 0
	if layer + 1 < data.size():
		next_layer_size = data[layer + 1].size()

	# go through each neuron
	for n in data[layer]:
		for w_index in next_layer_size:
			if w_index < n[2].size():
				n[2][w_index] = rand_range(0.0, 1.0)
			else:
				n[2].push_back(rand_range(0.0, 1.0))

			# randomize bias
			if randomize_bias:
				n[1] = rand_range(bias_min, bias_max)

func update_neurons():
	for l_index in data.size():
		if l_index > 0: # ignore first layer

			# get layer data arrays
			var l = data[l_index]
			var l_prev = data[l_index - 1]

			# go through each neuron (outputs)
			for n_index in l.size():
				# get current neuron (output)
				var n = l[n_index]

				# starts off by setting equal to the bias
				var sum = n[1]
				for n_prev in l_prev:
					# get prev neuron's weight
					var w = 0.0
					if n_index < n_prev[2].size():
						w = n_prev[2][n_index]
					# prev. neuron activation * conn. weight
					sum += n_prev[0] * w

				# ReLU
				sum = max(0.0, sum)
				n[0] = sum

#####

func _ready():
	pass # Replace with function body.

var time = 0

var profiling = [
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
]

var last_delta = 0
func _process(delta):
	last_delta = delta
	time += delta

	# construct data arrays if they aren't yet initialized (or are partial)
	check_init_data_array_sizes()

	# randomize weights
	if time > 1.0:
		time -= 1.0
		var t = OS.get_system_time_msecs()
		randomize_neuron_weights(0, false)
		randomize_neuron_weights(1, true, -4000, -500)
		randomize_neuron_weights(2, true, -2000, -500)
		randomize_neuron_weights(3, true, -2000, -500)
		profiling[0] = OS.get_system_time_msecs() - t

	# randomize inputs
	var t = OS.get_system_time_msecs()
	randomize_neuron_inputs()
	profiling[1] = OS.get_system_time_msecs() - t

	# update
	t = OS.get_system_time_msecs()
#	update_neurons()
	profiling[2] = OS.get_system_time_msecs() - t

	# draw
	update()

func _draw():
	var t = OS.get_system_time_msecs()

	if label == null:
		label = $Label
	label.text = "Delta: " + str(last_delta)
	label.text += "\nRand. weights:     " + str(profiling[0])
	label.text += "\nRand. activations: " + str(profiling[1])
	label.text += "\nNeuron updates:    " + str(profiling[2])
	label.text += "\nDraw calls:        " + str(profiling[3])
	label.text += "\n"
	label.text += "\n" + str(profiling[4])
	label.text += "\n" + str(profiling[5])
	label.text += "\n" + str(profiling[6])
	label.text += "\n" + str(profiling[7])
	label.text += "\n" + str(profiling[8])
	###
	label.text += "\n" + str(TESTLIB.get_heartbeat("test"))

	for l_index in range(data.size()):
		# get layer data array
		var l = data[l_index]

		# get next (destination) layer data array
		var next_l = null
		if l_index + 1 < data.size():
			next_l = data[l_index + 1]

		# iterate over every neuron
		for n_index in range(l.size()):

			# get neuron object
			var n = l[n_index]

			# draw synapses
			var pos = get_pos(l_index, n_index, l.size())
#			if next_l != null:
#				for w_index in next_l.size():
#					if n_index > l.size() - sizes[l_index]["max_row"]:
#						var w = 0.0
#						if w_index < n[2].size():
#							w = n[2][w_index]
#						var pos2 = get_pos(l_index + 1, w_index, next_l.size())
#						draw_line(pos + Vector2(3, 3), pos2 + Vector2(3, 3), Color(0,0,0,1).linear_interpolate(Color(1,0,0,1), w))

			# draw neuron
			draw_rect(Rect2(pos.x, pos.y, 6, 6), Color(0,0,0,1).linear_interpolate(Color(1,1,1,1), n[0]))


	profiling[3] = OS.get_system_time_msecs() - t
