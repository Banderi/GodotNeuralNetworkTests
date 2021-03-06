extends Node

onready var NeuralNetwork = load("res://bin/test.gdns").new()

 # for debugging.
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

var curr_database = "digits"

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

# ==== TOTALS =====
# layers:   4
# neurons:  4166
# synapses: 164840

func get_database_path():
	return "res://DATABASES/" + curr_database + ".dat"
func check_init_data_array_sizes():

	# first, add layers as needed if any is missing
	while data.size() < config.size():
		data.push_back([])

	for layer_i in config.size():
		var layer_info = config[layer_i]
		var layer = data[layer_i]

		# secondly, add neurons as needed if any is missing
		while layer.size() < layer_info["size"]:
			layer.push_back([0.0, 0.0, [], 0.0])
func initialize_network_data():

	### check if database case EXIST within the files
	var database = Files.loadfile(get_database_path())
	if database != null:
		data = database
	else: # no database found! start from scratch!
		data = []
		# construct data arrays if they aren't yet initialized (or are partial)
		check_init_data_array_sizes()

		# randomize inputs
		Profiler.clock_in("rand_activ_local")
		randomize_neuron_inputs()
		Profiler.clock_out("rand_activ_local")

		# randomize weights
		Profiler.clock_in("rand_weights_local")
		randomize_neuron_weights(0, false)
		randomize_neuron_weights(1, true, -40, -5)
		randomize_neuron_weights(2, true, -20, -5)
		randomize_neuron_weights(3, true, -20, -5)
		Profiler.clock_out("rand_weights_local")

###

# ====== THE PLAN SO FAR: =======
# - ???
# - compute the EXPECTED RESULTS on the local (gdscript) end with below function
# - pass EXPECTED RESULTS array to GDNative library
# - calculate COST on the GDNative library end
# - calculate backpropagation on the GDNative library end

var correct_digit = null
var network_answer_digit = -2
var network_answer_cost = 0.0

func get_favorable_final_layer():
	if correct_digit == null:
		return null
	var values = [0,0,0,0,0,0,0,0,0,0] # default - no neurons are lit
	if correct_digit >= -1:
		values[correct_digit] = 1.0
	return values
func get_network_answer_digit():
	var res = NeuralNetwork.get_answer_digit()
	network_answer_digit = res[0]
	network_answer_cost = res[1]

	var txt = network_answer_digit
	if txt == -1:
		txt = "?"
	elif txt < -1:
		txt = ""
	return txt

var cost_allowance_coeff = 0.5
func is_cost_acceptable():
	return 1.0 - min(network_answer_cost * cost_allowance_coeff, 1.0)

var time = 0.0
func update_backpropagation(delta):
	time += delta
	if time > 0.0 && correct_digit != null:
		time = 0.0
		Profiler.clock_in("input_backprop")

		# get the EXPECTED results, to send to the NN
		var favorable = get_favorable_final_layer()

		# black magic!!!
		NeuralNetwork.update_backpropagation(favorable)

		Profiler.clock_out("input_backprop")

###

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
				n[2][w_index] = rand_range(-1.0, 1.0)
			else:
				n[2].push_back(rand_range(-1.0, 1.0))

			# randomize bias
			if randomize_bias:
				n[1] = rand_range(bias_min, bias_max)

var last_hash = null
func update_local_input(board):

	# fetch inputs from drawing board, update database
	Profiler.clock_in("input_activ_update")
	var inputs = board.fetch_values()
	for n in data[0].size():
		data[0][n][0] = inputs[n]
	Profiler.clock_out("input_activ_update")

	# upload current input values to library
	Profiler.clock_in("store_values")
	var curr_hash = hash(data)
	if (curr_hash != last_hash): # do not update values if nothing has changed.
		NeuralNetwork.load_neuron_values(data)
	last_hash = curr_hash
	Profiler.clock_out("store_values")

func fetchset_neuron_synapses(l, n):
	# this is INSANELY SLOW. NOT VIABLE
#	for s in data[l][n][2].size():
#		var weight = NeuralNetwork.fetch_neuron_synapse_single(l, n, s)
#		data[l][n][2][s] = weight # synapses!!

	# this one is SLOW, but better...
	var syn = NeuralNetwork.fetch_neuron_synapse_weights(l, n) # this is inSANELY SLOWW
	data[l][n][2] = syn # synapses!!

func fetchset_neuron_state(l, n):
	var res = NeuralNetwork.fetch_single_neuron(l, n)
	data[l][n][0] = res[0] # activation
	data[l][n][1] = res[1] # bias
	if correct_digit != null:
		data[l][n][3] = res[2] # goal
	else:
		data[l][n][3] = 0.0

func fetchset_full_database():
	for l in data.size():
		for n in data[l].size():
			fetchset_neuron_state(l, n)
func fetchset_synapse_weights():
	for l in data.size():
		for n in data[l].size():
			fetchset_neuron_synapses(l, n)

func update_nn():
	# update GDNative library!
	var success = NeuralNetwork.update();
	if success:
		pass

###########

func _ready():

	# load up database caches from files, construct, etc.
	initialize_network_data()

	# upload data to GDNative...
	NeuralNetwork.load_neuron_values(data)

	# set hash for fast update checking
	last_hash = hash(data)
