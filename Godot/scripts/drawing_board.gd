extends TextureRect

var mouse_is_inside = false

var img = null

var last_pos = null
func draw(pos, inbetweens = false):

	if !inbetweens:
		# no draw on mouse being still!
		if pos == last_pos:
			return

	img.lock()
	for x in range(max(pos.x - 5, 0), min(pos.x + 5, 64)):
		for y in range(max(pos.y - 5, 0), min(pos.y + 5, 64)):

			var col = Color(1,1,1) * 0.25/pow(Vector2(x, y).distance_squared_to(pos), 4) + img.get_pixel(x, y)

			img.set_pixel(x, y, col)
	img.unlock()
	texture.create_from_image(img, 0)

	if !inbetweens:
		# too much lag!! fill in the points...
		if last_pos != null:
			var distance = pos.distance_to(last_pos)
			if distance > 1.0:
				var vec = (pos - last_pos) / distance
				for d in distance:
					draw(last_pos + vec * d, true)

		last_pos = pos

func fetch_values():
	var inputs = []
	img.lock()
	if img != null:
		for x in 64:
			for y in 64:
				var col = img.get_pixel(x, y)
				inputs.push_back(col.v)
	img.unlock()
	return inputs

###

func _process(delta):
	Profiler.clock_in("draw_board")

	# click
	if Input.is_action_pressed("mouse_left"):
		draw(get_local_mouse_position())
	else:
		last_pos = null

	Profiler.clock_out("draw_board")

func _on_drawingBoard_mouse_entered():
	mouse_is_inside = true

func _on_drawingBoard_mouse_exited():
	mouse_is_inside = false

func _on_btn_clear_pressed():
	img.fill(Color())
	texture.create_from_image(img, 0)


###

func _ready():
	img = Image.new()
	img.create(64, 64, false, Image.FORMAT_RGB8)
	texture = ImageTexture.new()
	texture.create_from_image(img, 0)
