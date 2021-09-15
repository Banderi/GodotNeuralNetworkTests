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


func parenth(a, b):
	return " (" + str(a) + "," + str(b) + ")"
func test_identity(a, b, values = false):
	var text = ""

	text += " RAW: " + str(a == b)
	if values:
		text += parenth(a, b)
	text += " --- BYTES: " + str(var2bytes(a) == var2bytes(b)) #+ parenth(var2bytes(a), var2bytes(b))
	text += " --- TYPES: " + str(typeof(a) == typeof(b)) + parenth(typeof(a), typeof(b))

	print(text)


func fetchset_neuron_state(l, n):
	var res = NeuralNetwork.fetch_single_neuron(l, n)

	var prev = data[l][n][0]

	data[l][n][0] = res

	var p = 0
	pass
func fetchset_layer_values(l):
	for n in data[l].size():
		fetchset_neuron_state(l, n)
func fetchset_full_database():
	for l in data.size():
		fetchset_layer_values(l)

func update_nn():

	# upload current input values to library
	Profiler.clock_in("store_values")
	NeuralNetwork.load_neuron_values(data)
	Profiler.clock_out("store_values")

	# update GDNative library!
	Profiler.clock_in("update_nn")
	var success = NeuralNetwork.update();
	if success:
		pass
	Profiler.clock_out("update_nn")


	# hopefully.....
	Profiler.clock_in("fetchset_one_by_one")
	fetchset_full_database()
	Profiler.clock_out("fetchset_one_by_one")

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
	randomize_neuron_weights(0, false)
	randomize_neuron_weights(1, true, -4000, -500)
	randomize_neuron_weights(2, true, -2000, -500)
	randomize_neuron_weights(3, true, -2000, -500)
	Profiler.clock_out("rand_weights_local")

	# upload data to GDNative...
	NeuralNetwork.load_neuron_values(data)
#	var res = NeuralNetwork.retrieve_neuron_values()
#	print(var2bytes(res[0][0]) == var2bytes(data[0][0]))
#	pass
