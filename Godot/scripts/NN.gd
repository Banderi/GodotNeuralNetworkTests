extends Node

onready var NeuralNetwork = load("res://bin/test.gdns").new()

var data = []
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

func update_nn():
	# update GDNative library and retrieve results!

	var success = NeuralNetwork.update();
	if success:
		pass
	data = NeuralNetwork.retrieve_neuron_values()
	pass

###########

func _ready():
	# construct data arrays if they aren't yet initialized (or are partial)
	check_init_data_array_sizes()

	# randomize inputs
	Profiler.clock_in("rand_activ_local")
	randomize_neuron_inputs()
	Profiler.clock_out("rand_activ_local")

	# randomize weights
	Profiler.clock_in("rand_weights_local")
	NN.randomize_neuron_weights(0, false)
	NN.randomize_neuron_weights(1, true, -4000, -500)
	NN.randomize_neuron_weights(2, true, -2000, -500)
	NN.randomize_neuron_weights(3, true, -2000, -500)
	Profiler.clock_out("rand_weights_local")

	# upload data to GDNative...
	NeuralNetwork.load_neuron_values(data)
