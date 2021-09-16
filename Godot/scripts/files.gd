extends Node

func savefile(path, data):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(data)
	file.close()
func loadfile(path):
	var file = File.new()
	if not file.file_exists(path):
		return null
	file.open(path, File.READ)
	var data = file.get_var()
	file.close()
	return data
