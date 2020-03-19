extends Node

# nome do arquivo
var save_path = "user://game_0.0.0.1.data"

# variável base do nosso jogo
var base_data: Dictionary = {
	"level": 1,
	"points": 0
}

# variável local, o jogo ficará trabalhando com ela e não com o arquivo
var save_data: Dictionary = base_data

# sinal para quando salvar o arquivo
signal onSave(data)

func _ready() -> void:
	# Cria um arquivo se não existir, ou carrega o existente
	newOrLoadFile(save_path, save_data)

func newOrLoadFile(_path, _data) -> void:
	save_data = _data
	var fl = File.new()
	# Se não existe um arquivo de save, cria
	if not fl.file_exists(save_path):
		fl.open(_path, File.WRITE)
		fl.store_var(_data)
		fl.close()
	else:
		# Se existe carrega o arquivo
		loadSavedGame()

func loadSavedGame() -> Dictionary:
	var fl = File.new()
	# Carrega os dados que estão no arquivo para a variavél local
	if fl.file_exists(save_path):
		fl.open(save_path, File.READ)
		save_data = fl.get_var()
		save_data["saved"] = 1 # controle para saber se a variável está modificada
		fl.close()
	return save_data
	
func readData(campo, notExistsReturn = 0):
	var ret = notExistsReturn
	# Obtém algum valor da variável local, se não existir retorna a variavel informada no parâmetro
	if save_data != null:
		if save_data.has(str(campo)):
			ret = save_data[str(campo)]
	return ret
	
func onlySaveData(forceSave = false) -> void:
	if !save_data.has("saved"): return
	# Se a variavel local já está salva então sai, e também se não é pra forçar o save
	if save_data["saved"] == 1 and !forceSave: return
	
	# Se a variável está modificada
	# Ou o forceSave é TRUE
	var fl = File.new()
	fl.open(save_path, File.WRITE)
	fl.store_var(save_data)
	fl.close()
	save_data["saved"] = 1 # coloca a variável local como salva
	emit_signal("onSave", save_data) # emite um sinal de save

func saveData(campos, type = "overwrite") -> void:
	if save_data != null: # Se a variável não for null
		for campo in campos.keys(): # procura todas as chaves informadas no parâmetro
			if type == "increment": # se for um campo que é para incrementar, pega o valor que tinha antes e incrementa
				if save_data.has(str(campo)):
					save_data[str(campo)] = int(save_data[str(campo)]) + int(campos[campo])
				else: # Se for para sobrescrever, então coloca o valor enviado no dicionario
					save_data[str(campo)] = campos[campo]
			else: # Se a chave não existe no dicionario local, então cria
				save_data[str(campo)] = campos[campo]
				
		save_data["version"] = (int(save_data["version"]) + 1) if save_data.has("version") else 0 # cria uma versão para a variável
		save_data["saved"] = 0 # marca a variável como salva

func deleteFileSave() -> void:
	var fl = File.new()
	# Se o arquivo existe, exclui
	if fl.file_exists(save_path):
		var dir = Directory.new()
		if !dir.current_is_dir():
			dir.remove(save_path)
			
			
			save_data = base_data
