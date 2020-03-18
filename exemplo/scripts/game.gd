extends Node

var date = OS.get_date()

var save_path = "user://game_0.0.0.1.data"
var save_data = {
	"level": 1,
	"points": 1
}

func _ready():
	newOrLoadFile(save_path, save_data)

func newOrLoadFile(_path, _data):
	save_data = _data
	var fl = File.new()
	if not fl.file_exists(save_path):
		fl.open(_path, File.WRITE)
		fl.store_var(_data)
		fl.close()
	else:
		loadSavedGame()

func loadSavedGame():
	var fl = File.new()
	if fl.file_exists(save_path):
		fl.open(save_path, File.READ)
		save_data = fl.get_var()
		save_data["saved"] = 1
		fl.close()
	return save_data
	
func readData(campo):
	var ret = 0
	if save_data != null:
		if save_data.has(str(campo)):
			ret = save_data[str(campo)]
	return ret
	
func onlySaveData():
	var fl = File.new()
	fl.open(save_path, File.WRITE)
	fl.store_var(save_data)
	fl.close()
	save_data["saved"] = 1

func saveData(campos, type = "overwrite"):
	if save_data != null:
		for campo in campos.keys():
			if type == "increment":
				if save_data.has(str(campo)):
					save_data[str(campo)] = int(save_data[str(campo)]) + int(campos[campo])
				else:
					save_data[str(campo)] = campos[campo]
			else:
				save_data[str(campo)] = campos[campo]
				
		save_data["version"] = (int(save_data["version"]) + 1) if save_data.has("version") else 0
		save_data["saved"] = 0
