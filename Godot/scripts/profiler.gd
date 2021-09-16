extends Node

var profiling = {
	"fps": 0,
	"profiling": 0,
	"frame_delta": null,
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
func time(id, corr = 0.001, average = false):
	if !profiling.has(id) || profiling[id] == null:
		return null
	if average:
		return profiling_temp[id][4] * corr
	else:
		return profiling[id] * corr
func time_formatted(id, corr = 0.001, average = false, unit = ""):
	if !profiling.has(id) || profiling[id] == null:
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

func _process(delta):

	# fps
	profiling["fps"] = Performance.get_monitor(0)
	profiling_temp["fps"][1] = profiling["fps"]
	Profiler.clock_flush("fps")

	# SPECIAL...
	profiling_temp["profiling"][2] += 1 # flushes tally
	profiling_temp["profiling"][3] += profiling["profiling"] # total!
	profiling_temp["profiling"][4] = profiling_temp["profiling"][3] / profiling_temp["profiling"][2] # average!!
	profiling["profiling"] = 0

func _ready():
	for id in profiling:
		profiling_temp[id] = [0,0,0,0,0]

