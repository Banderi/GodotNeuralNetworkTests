extends Node

onready var NeuralNetwork = load("res://bin/test.gdns").new()

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

###

# ====== THE PLAN SO FAR: =======
# - ???
# - compute the EXPECTED RESULTS on the local (gdscript) end with below function
# - pass EXPECTED RESULTS array to GDNative library
# - calculate COST on the GDNative library end
# - calculate backpropagation on the GDNative library end

#func cost(correct, bogus):
#	var sum = 0
#	for n in correct.size():
#		var diff = bogus[n][0] - correct[n][0]
#		sum += diff * diff
#	return sum

func get_favorable_final_layer():
	# TODO!
	return [0,0,0,0,0,0,0,0,0,0]

func update_backpropagation():

	# get cost for current state
	var favorable = get_favorable_final_layer()
#	var bogus = data[data.size() - 1]
#	var cc = cost(correct, bogus)

	# black magic!!!
	NeuralNetwork.update_backpropagation(favorable)


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
				n[2][w_index] = rand_range(0.0, 1.0)
			else:
				n[2].push_back(rand_range(0.0, 1.0))

			# randomize bias
			if randomize_bias:
				n[1] = rand_range(bias_min, bias_max)

var time = 0.0
func update_local_randomizations(delta):
	time += delta

	# randomize weights & biases
	if time > 1.0:
		time = 0.0
		Profiler.clock_in("rand_weights_local")
		randomize_neuron_weights(0, false)
		randomize_neuron_weights(1, true, -200, -150)
		randomize_neuron_weights(2, true, -20, -5)
		randomize_neuron_weights(3, true, -20, -5)
		Profiler.clock_out("rand_weights_local")
func update_local_input(board):

	# update inputs from drawing board
	Profiler.clock_in("input_activ_update")
	var inputs = board.fetch_values()
	for n in data[0].size():
		data[0][n][0] = inputs[n]
	Profiler.clock_out("input_activ_update")

	# upload current input values to library
	Profiler.clock_in("store_values")
	NeuralNetwork.load_neuron_values(data)
	Profiler.clock_out("store_values")

func fetchset_neuron_state(l, n):
	var res = NeuralNetwork.fetch_single_neuron(l, n)
	data[l][n][0] = res
func fetchset_layer_values(l):
	for n in data[l].size():
		fetchset_neuron_state(l, n)
func fetchset_full_database():
	for l in data.size():
		fetchset_layer_values(l)

func update_nn():
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

	# save data to drive!!
	Profiler.clock_in("cache_serialization")
	savetofile(get_database_path(), data)
	Profiler.clock_out("cache_serialization")

###

func savetofile(path, data):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(data)
	file.close()
func loadfromfile(path):
	var file = File.new()
	if not file.file_exists(path):
		return null
	file.open(path, File.READ)
	var data = file.get_var()
	file.close()
	return data

#func load_res(): # load resources, textures, descriptions, etc. from disk
#	var data_file = File.new()
#	if data_file.open("res://data.json", File.READ) != OK:
#		get_tree().quit(); # Joseph: "OOOOH NOOOO"
#	var data_text = data_file.get_as_text()
#	data_file.close()
#	var data_parse = JSON.parse(data_text)
#	var valid = validate_json(data_text)
#	if valid != "" || data_parse.error != OK:
#		print("Got JSON file of size " + String(data_text.length()) + ";")
#		print("JSON parse error on line: " + String(data_parse.error_line) + " : " + String(data_parse.error_string))
#		get_tree().quit() # Joseph: "OOOOOOHH NOOOOOOOO"
#
#	var data = data_parse.result
#
#	settings = data["ini"]
#	items = data["res"]["items"]
#	characters = data["res"]["characters"]
#	cuts = data["res"]["cuts"]

func get_database_path():
	return "res://DATABASES/" + curr_database + ".dat"

func initialize_network_data():

	### check if database case EXIST within the files
	var database = loadfromfile(get_database_path())
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
		randomize_neuron_weights(1, true, -4000, -500)
		randomize_neuron_weights(2, true, -2000, -500)
		randomize_neuron_weights(3, true, -2000, -500)
		Profiler.clock_out("rand_weights_local")

###########

func _ready():

	initialize_network_data()

	# upload data to GDNative...
	NeuralNetwork.load_neuron_values(data)
