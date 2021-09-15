extends Node

var label = null

var profiling = {
	"fps": 0,
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
		profiling_temp[id] = [0,0,0,0,0]
	profiling_temp[id][0] = t # store first timestamp temporarily

	# SELF PROFILING...
	profiling["profiling"] += OS.get_ticks_usec() - t
func clock_out(id, flush = true):
	var t = OS.get_ticks_usec()
	if !profiling_temp.has(id):
		profiling_temp[id] = [0,0,0,0,0]
	var diff = t - profiling_temp[id][0] # time difference between current and last timestamp

	# retrieve temp storage
	var total_time_stored = profiling_temp[id][1]

	# final tally -- add up to the other values (if present)
	var final = total_time_stored + diff

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
		profiling_temp[id] = [0,0,0,0,0]
	profiling_temp[id][2] += 1 # flushes tally
	profiling_temp[id][3] += profiling_temp[id][1] # total!
	profiling_temp[id][4] = profiling_temp[id][3] / profiling_temp[id][2] # average!!
	profiling_temp[id][1] = 0 # flush diff

	# SELF PROFILING...
	profiling["profiling"] += OS.get_ticks_usec() - t
func time(id, corr = 0.001, average = true, unit = ""):
	if profiling[id] == null:
		return "--"
	if average:
		return str(profiling_temp[id][4] * corr) + unit
	else:
		return str(profiling[id] * corr) + unit

# for loop - 1 pass line cycle: 0.031~ microseconds
# for loop - 10 pass line cycle: 0.072~ microseconds
# for loop - 20 pass line cycle: 0.111~ microseconds
# ESTIMATE single pass line: 0.0042~~ microseconds

# single clock tick fetch: 0.212~ microseconds

# single GDNative "get_test_string" call: 0.395~ microseconds
# single GDNative "get_two" call: 0.195~ microseconds
# single GDNative "get_heartbeat" call: 0.356~ microseconds

# GDNative "load_neuron_values" call: 2.02~ microseconds

func text_line(txt):
	label.text += txt + "\n"
func text_prof_line(id, indentation = "", corr = 0.001, average = true, unit = " ms"):
	text_line(indentation + id + ": " + time(id, corr, average, unit))

func draw_text():

	# fps
	profiling["fps"] = Performance.get_monitor(0)
	profiling_temp["fps"][1] = profiling["fps"]
	Profiler.clock_flush("fps")

	# SPECIAL...
	profiling_temp["profiling"][2] += 1 # flushes tally
	profiling_temp["profiling"][3] += profiling["profiling"] # total!
	profiling_temp["profiling"][4] = profiling_temp["profiling"][3] / profiling_temp["profiling"][2] # average!!
	profiling["profiling"] = 0

	if label != null:
		label.text = ""

		text_prof_line("fps", "", 1.0, false, "")
		text_prof_line("profiling")

		text_prof_line("frame_delta", "", 1.0, false)
		text_prof_line("frame_total")

		text_line("")

		text_prof_line("update_local")
		text_prof_line("rand_activ_local", "> ")
		text_prof_line("rand_bias_local", "> ")
		text_prof_line("rand_weights_local", "> ")

		text_line("")

		text_prof_line("update_gdnative")
		text_prof_line("store_values", "> ")
		text_prof_line("update_nn", "> ")
		text_prof_line("fetchset_one_by_one", "> ")

		text_line("")

		text_prof_line("draw")
		text_prof_line("draw_text", "> ")
		text_prof_line("draw_neurons", "> ")
		text_prof_line("draw_synapses_first", "> ")
		text_prof_line("draw_synapses_second", "> ")

func _ready():
	for id in profiling:
		profiling_temp[id] = [0,0,0,0,0]

