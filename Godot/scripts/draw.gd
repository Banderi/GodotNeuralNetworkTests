#tool
extends Node2D

onready var NeuralNetwork = load("res://bin/test.gdns").new()
onready var label = $label

var data = [
	# empty!
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

func get_pos(layer, index, max_index):

	var info = config[layer]

	var row = index % info["max_row"]
	var column = index / info["max_row"]
	var x = o_x + info["x"] + (column * info["column_spacing"])
	var y = o_y + (row * info["row_spacing"]) - (min(max_index, info["max_row"]) * info["row_spacing"] * 0.5)
	return Vector2(x, y)

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

func update_nn():
	# upload data to GDNative...
	NeuralNetwork.load_neuron_values(data)

	# ...download new data from GDNative.
	var data2 = NeuralNetwork.retrieve_neuron_values()

#####

func _ready():
	pass # Replace with function body.

var time = 0

var profiling = {
	"profiling": 0,
#	"clock_fetching": 0,
	"frame_delta": null,
	"frame_total": null,
		"update_local": null,
			"rand_activ_local": null,
			"rand_bias_local": null,
			"rand_weights_local": null,
			"update_nn_local": null,
		"update_gdnative": null,
			"rand_activ_gdnative": null,
			"rand_bias_gdnative": null,
			"rand_weights_gdnative": null,
			"update_nn_gdnative": null,
		"draw": null,
			"draw_text": null,
			"draw_neurons": null,
			"draw_synapses": null,
}
var profiling_temp = {} # temp
func clock_in(id):
	var t = OS.get_ticks_usec()
	if !profiling_temp.has(id):
		profiling_temp[id] = [0,0]
	profiling_temp[id][0] = t # store first timestamp temporarily

	# SELF PROFILING...
	profiling["profiling"] += OS.get_ticks_usec() - t
func clock_out(id, flush = true):
	var t = OS.get_ticks_usec()
	if !profiling_temp.has(id):
		profiling_temp[id] = [0,0]
	var diff = t - profiling_temp[id][0] # time difference between current and last timestamp

	# retrieve temp storage
	var tally_stored = profiling_temp[id][1]

	# final tally -- add up to the other values (if present)
	var final = tally_stored + diff

	# update stored values
	profiling[id] = final
	profiling_temp[id][1] += diff
	if flush:
		clock_flush(id)

	# SELF PROFILING...
	profiling["profiling"] += OS.get_ticks_usec() - t
func clock_flush(id):
	var t = OS.get_ticks_usec()

	# flush out temp storage
	if !profiling_temp.has(id):
		profiling_temp[id] = [0,0]
	profiling_temp[id][1] = 0

	# SELF PROFILING...
	profiling["profiling"] += OS.get_ticks_usec() - t
func time(id, corr = 0.001):
	if profiling[id] == null:
		return "--"
	return str(profiling[id] * corr)

var count = 0
var count2 = 0
func clock_profiling_self_update():
	return
	var c = 100.0

	# for loop - 1 pass line cycle: 0.031~ microseconds
	# for loop - 10 pass line cycle: 0.072~ microseconds
	# for loop - 20 pass line cycle: 0.111~ microseconds
	# ESTIMATE single pass line: 0.0042~~ microseconds

	# single clock tick fetch: 0.212~ microseconds

	# single GDNative "get_test_string" call: 0.395~ microseconds
	# single GDNative "get_two" call: 0.195~ microseconds
	# single GDNative "get_heartbeat" call: 0.356~ microseconds

	# GDNative "load_neuron_values" call: 2.02~ microseconds


	##################
	var t = OS.get_ticks_usec()

	for i in range(c):
		NeuralNetwork.get_heartbeat()
#		NeuralNetwork.load_neuron_values(data)
#		OS.get_ticks_usec()

	var diff = (OS.get_ticks_usec() - t)
	##################

	var tally = diff / c
	count2 += tally
	count += 1
#	profiling["clock_fetching"] = tally
	profiling["clock_fetching"] = count2 / count

func _process(delta):
	clock_in("frame_total")
	profiling["frame_delta"] = delta
	time += delta

	# SPECIAL
	clock_profiling_self_update()

	# construct data arrays if they aren't yet initialized (or are partial)
	check_init_data_array_sizes()

	# randomize weights
	if time > 1.0:
		time -= 1.0
		clock_in("rand_weights_local")
		randomize_neuron_weights(0, false)
		randomize_neuron_weights(1, true, -4000, -500)
		randomize_neuron_weights(2, true, -2000, -500)
		randomize_neuron_weights(3, true, -2000, -500)
		clock_out("rand_weights_local")

	# randomize inputs
	clock_in("rand_activ_local")
	randomize_neuron_inputs()
	clock_out("rand_activ_local")

	# update neural network
#	clock_in("update_nn_local")
#	update_neurons()
#	clock_out("update_nn_local")

	clock_in("update_nn_gdnative")
	update_nn()
	clock_out("update_nn_gdnative")

	# draw
	update()

	clock_out("frame_total")

func _draw():
	clock_in("draw")

	# draw text
	clock_in("draw_text")
	if label == null:
		label = $Label
	label.text = ""
	for id in profiling:
		var v = time(id)
		label.text += "\n" + id + ": " + v
		pass
	profiling["profiling"] = 0 # SPECIAL...
	clock_out("draw_text")

	# draw graphics
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
#					if n_index > l.size() - config[l_index]["max_row"]:
#						var w = 0.0
#						if w_index < n[2].size():
#							w = n[2][w_index]
#						var pos2 = get_pos(l_index + 1, w_index, next_l.size())
#						draw_line(pos + Vector2(3, 3), pos2 + Vector2(3, 3), Color(0,0,0,1).linear_interpolate(Color(1,0,0,1), w))

			# draw neuron
			clock_in("draw_neurons")
			draw_rect(Rect2(pos.x, pos.y, 6, 6), Color(0,0,0,1).linear_interpolate(Color(1,1,1,1), n[0]))
			clock_out("draw_neurons", false)
	clock_flush("draw_neurons")


	clock_out("draw")
