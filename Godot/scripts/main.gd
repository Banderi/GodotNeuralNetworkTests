extends Node2D

onready var draw = $draw
onready var backdraw = $draw/back
onready var backdraw2 = $draw/back2
onready var label = $draw/Label
onready var drawingBoard = $drawingBoard
onready var answer = $ans/digit
onready var cost = $ans/cost
onready var shouldbe = $shouldbe/Label

###

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
		text_line("frame_total: " + str(frame_total) + " ms")

		text_line("")

		text_prof_line("update_local")
		text_prof_line("input_activ_update", "> ")
		text_prof_line("input_backprop", "> ")

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

		# I guess I can do this in here?
		update_cost_and_answer_texts()

func update_cost_and_answer_texts():
	# update result text
	answer.text = str(NN.get_network_answer_digit())
	# update "should be" text
	var correct_digit = NN.correct_digit
	if correct_digit == -99:
		shouldbe.text = "Should be: --"
	elif correct_digit < 0:
		shouldbe.text = "Should be: none"
	else:
		shouldbe.text = "Should be: " + str(correct_digit)
	# update cost text
	var answer_cost = stepify(NN.network_answer_cost, 0.001)
	cost.modulate = Color(1,0,0).linear_interpolate(Color(0,1,0), NN.is_cost_acceptable())
	if correct_digit < -2:
		answer_cost = ""
	elif answer_cost > 100:
		answer_cost = str(">100(!!)")
	cost.text = str(answer_cost)

###

var time = 0
func _process(delta):
	Profiler.clock_in("frame_process")
	Profiler.profiling["frame_delta"] = delta
	time += delta

	# local updates
	Profiler.clock_in("update_local")
	NN.update_local_input(drawingBoard)
	NN.update_backpropagation(delta)
	Profiler.clock_out("update_local")

	# gdnative library updates
	Profiler.clock_in("update_gdnative")
	NN.update_nn()
	Profiler.clock_out("update_gdnative")

	# save data to drive!!
	if time > 0.2:
		Profiler.clock_in("cache_serialization")
		Files.savefile(NN.get_database_path(), NN.data)
		Profiler.clock_out("cache_serialization")

	# draw
	Profiler.clock_in("draw")
	if time > 0.2:
		backdraw.update()
	backdraw2.update()
	draw.update()
	Profiler.clock_in("draw_text")
	draw_text()
	Profiler.clock_out("draw_text")
	Profiler.clock_out("draw", false)
	Profiler.clock_flush("draw")

	# reset clock
	if time > 0.2:
		time = 0.0

	Profiler.clock_out("frame_process")

func _ready():
	backdraw.onlyfirstlayer = true
	backdraw2.onlyfirstlayer = false

###

func _on_btn_shouldbe_pressed(digit):
	NN.correct_digit = digit
#	update_cost_and_answer_texts()
