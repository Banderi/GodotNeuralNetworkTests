extends Node

var label = null

var profiling = {
	"profiling": 0,
#	"clock_fetching": 0,
	"frame_delta": null,
	"frame_total": null,
		"update_local": null,
			"rand_activ_local": null,
			"rand_bias_local": null,
			"rand_weights_local": null,
		"update_gdnative": null,
			"store_values": null,
			"update_nn": null,
			"fetchset_one_by_one": null,
		"draw": null,
			"draw_text": null,
			"draw_neurons": null,
			"draw_synapses_first": null,
			"draw_synapses_second": null,
#			"draw_synapses": null,
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

# for loop - 1 pass line cycle: 0.031~ microseconds
# for loop - 10 pass line cycle: 0.072~ microseconds
# for loop - 20 pass line cycle: 0.111~ microseconds
# ESTIMATE single pass line: 0.0042~~ microseconds

# single clock tick fetch: 0.212~ microseconds

# single GDNative "get_test_string" call: 0.395~ microseconds
# single GDNative "get_two" call: 0.195~ microseconds
# single GDNative "get_heartbeat" call: 0.356~ microseconds

# GDNative "load_neuron_values" call: 2.02~ microseconds

func draw_text():

	if label != null:
		label.text = ""
		for id in profiling:
			var v = time(id)
			label.text += "\n" + id + ": " + v
			pass

	profiling["profiling"] = 0 # SPECIAL...
