extends Node2D

onready var draw = $draw
onready var backdraw = $draw/back
onready var backdraw2 = $draw/back2
onready var label = $draw/Label
onready var drawingBoard = $drawingBoard

func text_line(txt):
	label.text += txt + "\n"
func text_prof_line(id, indentation = "", corr = 0.001, average = true, unit = " ms"):
	text_line(indentation + id + ": " + Profiler.time_formatted(id, corr, average, unit))

func draw_text():

	if label != null:
		label.text = ""

		text_prof_line("fps", "", 1.0, false, "")
		text_prof_line("profiling")

		text_prof_line("frame_process")
		text_prof_line("frame_delta", "", 1.0, false, "")

		var frame_total = Profiler.time("frame_delta", 1000.0)
#		var frame_profiled = Profiler.time("update_local") + Profiler.time("update_gdnative") + Profiler.time("draw")
#		var frame_unaccounted_for = frame_total - frame_profiled
		text_line("frame_total: " + str(frame_total) + " ms")
#		text_line("frame_profiled: " + str(frame_profiled) + " ms")
#		text_line("frame_unaccounted_for: " + str(frame_unaccounted_for) + " ms")

		text_line("")

		text_prof_line("update_local")
		text_prof_line("input_activ_update", "> ")
		text_prof_line("rand_weights_local", "> ")

		text_line("")

		text_prof_line("update_gdnative")
		text_prof_line("store_values", "> ")
		text_prof_line("update_nn", "> ")
		text_prof_line("fetchset_one_by_one", "> ")
		text_prof_line("cache_serialization", "> ")

		text_line("")

		text_prof_line("draw")
		text_prof_line("draw_text", "> ")
		text_prof_line("draw_neurons", "> ")
		text_prof_line("draw_synapses_first", "> ")
		text_prof_line("draw_synapses_second", "> ")
		text_prof_line("draw_board", "> ", 0.001, false)

		text_line("")

		text_line(str(drawingBoard.mouse_is_inside))
		text_line(str(drawingBoard.get_local_mouse_position()))

###

var time = 0
func _process(delta):
	Profiler.clock_in("frame_process")
	Profiler.profiling["frame_delta"] = delta
	time += delta

	# local updates
	Profiler.clock_in("update_local")
#	NN.update_local_randomizations(delta)
	NN.update_local_input(drawingBoard)
	Profiler.clock_out("update_local")

	# gdnative library updates
	Profiler.clock_in("update_gdnative")
	NN.update_nn()
	Profiler.clock_out("update_gdnative")

	# draw
	Profiler.clock_in("draw")
	if time > 0.2:
		time = 0.0
		backdraw.update()
	backdraw2.update()
	draw.update()
	Profiler.clock_in("draw_text")
	draw_text()
	Profiler.clock_out("draw_text")
	Profiler.clock_out("draw", false)
	Profiler.clock_flush("draw")

	Profiler.clock_out("frame_process")

func _ready():
	backdraw.onlyfirstlayer = true
	backdraw2.onlyfirstlayer = false
