#родительский скрипт
extends Control

var classDate = preload("res://classDate.gd") #предзагрузка нового типа данных (дата)
var gamepadImg = preload("res://gamepad.png")
var movieImg = preload("res://movie.png")
var serialImg = preload("res://serial.png")
var bookImg = preload("res://book.png")
var mangaImg = preload("res://books.png")
var gamepadInterest = preload("res://gamepadInterest.png")
var movieInterest = preload("res://movieInterest.png")
var serialInterest = preload("res://serialInterest.png")
var bookInterest = preload("res://bookInterest.png")
var mangaInterest = preload("res://booksInterest.png")
var items = [] #массив элементов
var count_item = 0 #количество элементов
var add_new_item = false
var viewed = true
var onview = true
var notstarted = true
var sorting = false
var sort_local = false
var serialView = true
var movieView = true
var gameView = true
var bookView = true
var mangaView = true
var interestView = false
var add_word = ""
var copyWord = true
var copySeries = true
var last_file = "" #последний открытый файл
var select_item = -1 #текущий выбранный элемент
var old_item = -1
var sort_index = [] #массив сортировки
var current_item = [] #массив для показа
var file_path = "" #файл для открытия
var config = ConfigFile.new()
var file_is_save = true


########################## Работа с приложением и файловой системой #########
#при корректном выходе из приложения сохранение параметров приложения
func _notification(what):
	if(what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		if count_item <= 0:
			save_conf()
			get_tree().quit()
		elif file_is_save:
			save_conf()
			get_tree().quit()
		else:
			get_node("QuitDialog").show()

func _ready():
	#загрузка параметров приложения из файла находящегося рядом с приложением
	#если поменять res:// на user:// то файл будет грузиться из папки годота в app_data
	#при это не забыть поменять путь в фукнции save_conf()
	#чтобы узнать местонахождение папки user:// расскоментировать нижний принт
	#print(OS.get_data_dir()).
	var err = config.load("res://animelist.cfg")
	if err == OK:
		var winPos = Vector2(OS.get_screen_size().x/2 - 400.0, OS.get_screen_size().y/2 - 300.0)
		var winSize = Vector2(800,600)
		if(config.has_section("main")):
			if config.get_value("main", "view") != null: viewed = config.get_value("main", "view")
			if config.get_value("main", "onview") != null: onview = config.get_value("main", "onview")
			if config.get_value("main", "notview") != null: notstarted = config.get_value("main", "notview")
			if config.get_value("main", "sort") != null: sorting = config.get_value("main", "sort")
			if config.get_value("main", "local") != null: sort_local = config.get_value("main", "local")
			if config.get_value("main", "path") != null: last_file = config.get_value("main", "path")
			if config.get_value("main", "word") != null: add_word = config.get_value("main", "word")
			if config.get_value("main", "copyWord") != null: copyWord = config.get_value("main", "copyWord")
			if config.get_value("main", "copySeries") != null: copySeries = config.get_value("main", "copySeries")
			if config.get_value("main", "serial") != null: serialView = config.get_value("main", "serial")
			if config.get_value("main", "movie") != null: movieView = config.get_value("main", "movie")
			if config.get_value("main", "game") != null: gameView = config.get_value("main", "game")
			if config.get_value("main", "book") != null: bookView = config.get_value("main", "book")
			if config.get_value("main", "manga") != null: mangaView = config.get_value("main", "manga")
			if config.get_value("main", "interest") != null: interestView = config.get_value("main", "interest")
			if config.get_value("main", "posX") != null: winPos.x = config.get_value("main", "posX")
			if config.get_value("main", "posY") != null: winPos.y = config.get_value("main", "posY")
			if config.get_value("main", "winSizeX") != null: winSize.x = config.get_value("main", "winSizeX")
			if config.get_value("main", "winSizeY") != null: winSize.y = config.get_value("main", "winSizeY")
			if add_word != null: get_node("TabContainer/setings/Panel/addWord").set_text(add_word)
				
		OS.set_window_position(winPos)
		OS.set_window_size(winSize)
	else:
		OS.set_window_position(Vector2(OS.get_screen_size().x/2 - 400.0, OS.get_screen_size().y/2 - 300.0))
	#настройка параметрических нодов
	get_node("TabContainer/sortingSetting/Panel/notstarted").set_pressed(notstarted)
	get_node("TabContainer/sortingSetting/Panel/onview").set_pressed(onview)
	get_node("TabContainer/sortingSetting/Panel/viewed").set_pressed(viewed)
	get_node("TabContainer/sortingSetting/Panel/sorting").set_pressed(sorting)
	if sorting:
		get_node("TabContainer/sortingSetting/Panel/sort_local").show()
	else:
		get_node("TabContainer/sortingSetting/Panel/sort_local").hide()
	get_node("TabContainer/sortingSetting/Panel/sort_local").set_pressed(sort_local)
	get_node("TabContainer/sortingSetting/Panel/serial").set_pressed(serialView)
	get_node("TabContainer/sortingSetting/Panel/movie").set_pressed(movieView)
	get_node("TabContainer/sortingSetting/Panel/game").set_pressed(gameView)
	get_node("TabContainer/sortingSetting/Panel/interest").set_pressed(interestView)
	
	get_node("TabContainer/setings/Panel/copyWord").set_pressed(copyWord)
	get_node("TabContainer/setings/Panel/copyCurSeries").set_pressed(copySeries)
	
	get_node("FileDialog").set_access(FileDialog.ACCESS_FILESYSTEM)
	get_node("FileDialog").clear_filters()
	get_node("FileDialog").add_filter("*.list; AnimeList")
		
	get_node("FileMenu").get_popup().add_item("Новый",0)
	get_node("FileMenu").get_popup().add_separator()
	get_node("FileMenu").get_popup().add_item("Последний файл",1)
	get_node("FileMenu").get_popup().add_separator()
	get_node("FileMenu").get_popup().add_item("Открыть",2)
	get_node("FileMenu").get_popup().add_item("Сохранить",3)
	get_node("FileMenu").get_popup().add_item("Сохранить как...",4)
	get_node("FileMenu").get_popup().add_separator()
	get_node("FileMenu").get_popup().add_item("Выйти",5)
	get_node("FileMenu").get_popup().connect("item_pressed", self, "file_item_select")
	
#Выбор элемента меню
func file_item_select(ID):
	if(ID == 5): #выход
		if count_item <= 0:
			save_conf()
			get_tree().quit()
		elif  file_is_save:
			save_conf()
			get_tree().quit()
		else:
			get_node("QuitDialog").show()
	elif(ID == 0): #новый файл
		if not file_is_save:
			get_node("newFile").show()
		else:
			file_path = ""
			OS.set_window_title("AnimeList")
			clear_list()
			create_list()
	elif(ID == 1): #загрузка последнего открытого файла
		if(last_file != ""):
			load_list(last_file)
			file_path = last_file
			create_list()
	elif(ID == 2): #открыть
		get_node("FileDialog").set_mode(FileDialog.MODE_OPEN_FILE)
		get_node("FileDialog").show()
	elif(ID == 3): #сохранить файл
		if(file_path == ""): #если файл новый показывает окно сохранения
			get_node("FileDialog").set_mode(FileDialog.MODE_SAVE_FILE)
			get_node("FileDialog").show()
		else: #для перезаписи существующего файла
			#print("save")
			save_file(file_path)
	elif(ID == 4): #сохранить как...
		get_node("FileDialog").set_mode(FileDialog.MODE_SAVE_FILE)
		get_node("FileDialog").show()

#загрузка листа
func load_list(path_file):
	clear_list()
	last_file = path_file
	var ID = 0
	var file_open = File.new()
	var value_data
	file_open.open(path_file,1) #представляет собой CSV файл с разделителем ";"
	var new_list = false
	var set_version = false
	while(file_open.get_pos() < file_open.get_len()): #проверка на конец файла
		var data = file_open.get_csv_line(";")
		if not set_version:
			if data[0] == "$2.0": #проверяем является ли новой структурой списка, 1-ая строка файла выглядит как $2.0;
				new_list = true
				data = file_open.get_csv_line(";") #обязательно считываем новую строку
			set_version = true
		if not new_list:
			items.push_back(list_old(ID, data))
		else:
			items.push_back(list_new(ID, data))
		ID += 1
	file_is_save = true
	
	count_item = items.size()
	OS.set_window_title(str("AnimeList ", path_file))
	file_open.close()

#парсер старого листа
func list_old(ID, string):
	"""	0 - завершенность
		1 - оригинальное название
		2 - местное название
		3 - количество серий
		4 - количество просмотренного
		5 - дата релиза
		6 - даты переноса выхода серий
	"""
	var newItem
	var addDate = classDate.new()
	addDate.set_date_from_text("/", string[5], "dmy")
	if int(string[3]) > 1:
		 newItem = {"ID":ID, "type":"serial", "name_orig":string[1], "name_local":string[2], "series":int(string[3]), "views":int(string[4]), "reliese": addDate, "transfer":string[6], "interest":false}
	elif int(string[3]) == 1:
		newItem = {"ID":ID, "type":"movie", "name_orig":string[1], "name_local":string[2], "views":bool(int(string[4])), "reliese": addDate, "interest":false}
	return newItem
	
#парсер нового листа
func list_new(ID, string):
	"""	0 - тип объекта (serial, movie, game)
		1 - оригинальное название
		2 - перевод названия
		3 - дата релиза
		4 - если serial то количество просмотренного, если иное то 0 или 1
		5 - представляет ли для нас интерес
		только для serial
		6 - количество серий
		7 - даты переноса выхода серий 
	"""
	var addDate = classDate.new()
	addDate.set_date_from_text("/", string[3], "dmy")
	var newItem
	if string[0] == "serial" or string[0] == "manga": #структура если сериал
		newItem= {"ID":ID, "type":string[0], "name_orig":string[1], "name_local":string[2], "series":int(string[6]), "views":int(string[4]), "reliese": addDate, "transfer":string[7], "interest":bool(int(string[5]))}
	elif string[0] == "movie"  or string[0] == "game"  or string[0] == "book":
		newItem= {"ID":ID, "type":string[0], "name_orig":string[1], "name_local":string[2], "views":bool(int(string[4])), "reliese": addDate, "interest":bool(int(string[5]))}
	return newItem
	
#диалог открытия и сохранения файла
func _on_FileDialog_OK_but(): 
	if(get_node("FileDialog").get_mode() == FileDialog.MODE_OPEN_FILE): #открытие файла
		file_path = get_node("FileDialog").get_current_path()
		load_list(file_path)
		create_list()
	elif(get_node("FileDialog").get_mode() == FileDialog.MODE_SAVE_FILE): #сохранение файла
		save_file(get_node("FileDialog").get_current_path())

#сохранение файла, если нет расширения добавляем *.list иначе сохраняем как есть
func save_file(path): 
	var newFile = File.new()
	if(path.find(".list") == -1):
		newFile.open(str(path,".list"), 2)
	else:
		newFile.open(path, 2)
	newFile.store_line("$2.0;") #версия хранения данных
	"""	0 - тип объекта (serial, movie, game)
		1 - оригинальное название
		2 - перевод названия
		3 - дата релиза
		4 - если serial то количество просмотренного, если иное то 0 или 1
		5 - ожидаемый 
		только для serial
		5 - количество серий
		6 - даты переноса выхода серий 
	"""
	for i in range(items.size()):
		var sep = ";"
		var interest = 0
		var date = items[i]["reliese"].get_text_num()
		if items[i]["interest"]:
			interest = 1
		if items[i]["type"] == "serial" or items[i]["type"] == "manga":
			newFile.store_line(str( items[i]["type"], sep, items[i]["name_orig"], sep, items[i]["name_local"], sep, date, sep, items[i]["views"], sep, interest, sep, items[i]["series"],sep, items[i]["transfer"] ))
		if items[i]["type"] == "movie" or items[i]["type"] == "game" or items[i]["type"] == "book":
			var views = 0
			if items[i]["views"]:
				views = 1
			newFile.store_line(str( items[i]["type"], sep, items[i]["name_orig"], sep, items[i]["name_local"], sep, date, sep, views, sep, interest ))
	file_is_save = true
	newFile.close()

#сохранение файла конфигурации
func save_conf(): 
	config.set_value("main", "notview", notstarted)
	config.set_value("main", "view", viewed)
	config.set_value("main", "onview", onview)
	config.set_value("main", "sort", sorting)
	config.set_value("main", "local", sort_local)
	config.set_value("main", "path", last_file)
	config.set_value("main", "word", add_word)
	config.set_value("main", "copyWord", copyWord)
	config.set_value("main", "copySeries", copySeries)
	config.set_value("main", "serial", serialView)
	config.set_value("main", "movie", movieView)
	config.set_value("main", "game", gameView)
	config.set_value("main", "book", bookView)
	config.set_value("main", "manga", mangaView)
	config.set_value("main", "interest", interestView)
	config.set_value("main", "posX", OS.get_window_position().x)
	config.set_value("main", "posY", OS.get_window_position().y)
	config.set_value("main", "winSizeX", OS.get_window_size().x)
	config.set_value("main", "winSizeY", OS.get_window_size().y)
	config.save("res://animelist.cfg")

#справка
func _on_help_pressed(): 
	if(get_node("HelpDialog").is_visible()):
		get_node("HelpDialog").hide()
	else:
		get_node("HelpDialog").show()

########################## END ##################################


########################## Настройки приложения ######################
func _on_copyWord_toggled( pressed ):
	copyWord = pressed

func _on_copyCurSeries_toggled( pressed ):
	copySeries = pressed

func _on_addWord_text_entered( text ):
	add_word = get_node("TabContainer/setings/Panel/addWord").get_text()
########################## END ##################################


########################## Работа со списком #########################
#Очистка листа элементов
func clear_list():
	if not get_node("TabContainer/info/Control").is_hidden():
		get_node("TabContainer/info/Control").hide()
	select_item = -1
	count_item = 0
	items.clear()
	file_is_save = false
	
#выбор элемента для просмотра
func _on_ItemList_item_selected( index ): 
	if(!items.empty()):
		if get_node("TabContainer/info/Control").is_hidden():
			get_node("TabContainer/info/Control").show()
		old_item = index
		if items[ current_item[index] ]["type"] == "serial" or items[ current_item[index] ]["type"] == "manga": #если выбран многосерийник
			get_node("TabContainer/info/Control/many/views").set_value(0)
			get_node("TabContainer/info/Control/many").show()
			get_node("TabContainer/info/Control/one").hide()
			get_node("TabContainer/info/Control/many/name_orig").set_text(items[current_item[index]]["name_orig"])
			get_node("TabContainer/info/Control/many/name_local").set_text(items[current_item[index]]["name_local"])
			get_node("TabContainer/info/Control/many/series").set_text(str(items[current_item[index]]["series"]))
			get_node("TabContainer/info/Control/many/views").set_max(float(items[current_item[index]]["series"]))
			get_node("TabContainer/info/Control/many/views").set_value(float(items[current_item[index]]["views"]))
			get_node("TabContainer/info/Control/many/reliese").set_text(items[current_item[index]]["reliese"].get_text())
			get_node("TabContainer/info/Control/many/interestView").set_pressed(items[current_item[index]]["interest"])
			get_node("date_series").set_series(items[current_item[index]])
			var type = "Многосерийник"
			if items[current_item[index]]["type"] == "manga":
				type = "Многотомник"
			get_node("TabContainer/info/Control/many/type").set_text(type)
		else:
			get_node("TabContainer/info/Control/many").hide()
			get_node("TabContainer/info/Control/one").show()
			get_node("date_series").clear()
			get_node("TabContainer/info/Control/one/name_orig").set_text(items[current_item[index]]["name_orig"])
			get_node("TabContainer/info/Control/one/name_local").set_text(items[current_item[index]]["name_local"])
			get_node("TabContainer/info/Control/one/views").set_pressed(items[current_item[index]]["views"])
			get_node("TabContainer/info/Control/one/reliese").set_text(items[current_item[index]]["reliese"].get_text())
			get_node("TabContainer/info/Control/one/interestView").set_pressed(items[current_item[index]]["interest"])
			var type = "Односерийник"
			if items[current_item[index]]["type"] == "game":
				type = "Игра"
			elif items[current_item[index]]["type"] == "book":
				type = "Однотомник"
			get_node("TabContainer/info/Control/one/type").set_text(type)
		select_item = index
			
#создание нового листа элементов и сортировка по названию
func create_list(): 
	get_node("ItemList").clear()
	current_item.clear()
	sort_index.clear()
	if(sorting && !items.empty()): #Сортировка списка
		if(sort_local): #По переводу названия
			sort_index.push_back(items[0]["ID"])
			for i in range(1, items.size()):
				var str1 = items[i]["name_local"]
				var sort_count = sort_index.size()
				for s in range(sort_count):
					var str2 = items[sort_index[s]]["name_local"]
					if(str1.casecmp_to(str2) <= 0):
						sort_index.insert(s, items[i]["ID"])
						break
					elif(str1.casecmp_to(str2) == 1 && s == sort_count - 1):
						sort_index.push_back(items[i]["ID"])
		else: #по оригинальному названию
			sort_index.push_back(items[0]["ID"])
			for i in range(1, items.size()):
				var str1 = items[i]["name_orig"]
				var sort_count = sort_index.size()
				for s in range(sort_count):
					var str2 = items[sort_index[s]]["name_orig"]
					if(str1.casecmp_to(str2) <= 0):
						sort_index.insert(s, items[i]["ID"])
						break
					elif(str1.casecmp_to(str2) == 1 && s == sort_count - 1):
						sort_index.push_back(items[i]["ID"])
	elif(items.size() !=0): #отсутствие сортировки
		for i in range(count_item):
			sort_index.push_back(i)
	if(!items.empty()):#построение списка для показа
		for i in range(count_item):
			if viewed: #просмотренно
				if items[ sort_index[i] ]["type"] == "serial" and serialView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["series"] == items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["series"] == items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "manga" and mangaView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["series"] == items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["series"] == items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "movie" and movieView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "game" and gameView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "book" and bookView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
			if onview: #просмотр
				if items[ sort_index[i] ]["type"] == "serial" and serialView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["views"] > 0 && items[ sort_index[i] ]["series"] > items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["views"] > 0 && items[ sort_index[i] ]["series"] > items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "manga" and mangaView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[ sort_index[i] ]["views"] > 0 && items[ sort_index[i] ]["series"] > items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if items[ sort_index[i] ]["views"] > 0 && items[ sort_index[i] ]["series"] > items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
			if notstarted: #не начинали
				if items[ sort_index[i] ]["type"] == "serial" and serialView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[sort_index[i]]["views"] == 0:
								add_item(sort_index[i])
					else:
						if items[sort_index[i]]["views"] == 0:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "manga" and mangaView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if items[sort_index[i]]["views"] == 0:
								add_item(sort_index[i])
					else:
						if items[sort_index[i]]["views"] == 0:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "movie" and movieView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if not items[sort_index[i]]["views"]:
								add_item(sort_index[i])
					else:
						if not items[sort_index[i]]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "game" and gameView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if not items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if not items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				if items[ sort_index[i] ]["type"] == "book" and bookView:
					if interestView:
						if items[ sort_index[i] ]["interest"]:
							if not items[ sort_index[i] ]["views"]:
								add_item(sort_index[i])
					else:
						if not items[ sort_index[i] ]["views"]:
							add_item(sort_index[i])
				
		if(get_node("ItemList").get_item_count() == 0):
			get_node("ItemList").add_item("Нет Элементов для показа")
	else:
		get_node("ItemList").add_item("Нет Элементов для показа")
	
	get_node("Label").set_text(str("Общее количество: ", items.size(), " | Количество показаного: ", current_item.size()))

#добавление элемента в список просмотра и цветовая идентификация элементов
func add_item(i): 
	current_item.push_back(items[i]["ID"])
	var transferDate = []
	var date  = classDate.new()
	var currentDay = classDate.new()
	currentDay.set_current_date()
	date.set_equal(items[i]["reliese"])
	if items[i]["type"] == "serial" or items[i]["type"] == "manga":
		if(items[i]["transfer"].length() > 0):
			var str1 = items[i]["transfer"].split(":",false)
			for i in range(str1.size()):
				var str2 = str1[i].split("-",false)
				var trDate = classDate.new()
				trDate.set_date_from_text("/",str2[1],"dmy")
				var addItem = {"series":int(str2[0]),"date":trDate}
				transferDate.push_back(addItem)
	
	get_node("ItemList").add_item(str(items[i]["name_orig"],", ", items[i]["name_local"])) #добавление элемента "Оригинальное название, перевод" 
	if items[i]["type"] == "game": 
		if items[i]["interest"]:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, gamepadInterest)#добавление иконки
		else:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, gamepadImg)#добавление иконки
	elif items[i]["type"] == "movie":
		if items[i]["interest"]:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, movieInterest)#добавление иконки
		else:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, movieImg)#добавление иконки
	elif items[i]["type"] == "serial":
		if items[i]["interest"]:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, serialInterest)#добавление иконки
		else:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, serialImg)#добавление иконки
	elif items[i]["type"] == "book":
		if items[i]["interest"]:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, bookInterest)#добавление иконки
		else:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, bookImg)#добавление иконки
	elif items[i]["type"] == "manga":
		if items[i]["interest"]:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, mangaInterest)#добавление иконки
		else:
			get_node("ItemList").set_item_icon(get_node("ItemList").get_item_count()-1, mangaImg)#добавление иконки
		
	var green = Color(0.0,0.2,0.0) #зеленый
	var red = Color(0.2,0.0,0.0) #красный
	var blue = Color(0.0,0.0,0.2) #синий
	var orange = Color(0.3, 0.1, 0.0) #темно-оранжевый
	var orangeLite = Color(0.5, 0.2, 0.0) #светло-оранжевый
	
	var anons = classDate.new() 
	anons.set_equal(items[i]["reliese"])
	anons.offset_day(7)
	if currentDay.less(items[i]["reliese"]): #анонс
		if items[i]["type"] == "serial" or items[i]["type"] == "manga":
			if items[i]["views"] == 0:
				get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, orange) #изменение цвета элемента
		elif items[i]["type"] == "movie" or items[i]["type"] == "game":
			if not items[i]["views"]:
				get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, orange) #изменение цвета элемента
	elif currentDay.less(anons): #в течении 7 дней после релиза
		if items[i]["type"] == "serial" or items[i]["type"] == "manga":
			if items[i]["views"] == 0:
				get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, orangeLite) #изменение цвета элемента
		elif items[i]["type"] == "movie" or items[i]["type"] == "game":
			if not items[i]["views"]:
				get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, orangeLite) #изменение цвета элемента
	
	if items[i]["type"] == "serial" or items[i]["type"] == "manga":
		if items[i]["series"] == items[i]["views"]: #просмотренно
			get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, blue) #изменение цвета элемента
		elif items[i]["series"] > items[i]["views"] && items[i]["views"] != 0: #если смотрим
			var color
			var lastSeries = -1
			if(transferDate.size() > 0):
				for s in range(transferDate.size()):
					if(transferDate[s]["series"] <= items[i]["views"]):
						date.set_equal(transferDate[s]["date"])
						lastSeries = transferDate[s]["series"]
			else:
				date.offset_day(7*(items[i]["views"]-1))
			
			if(lastSeries != -1):
				date.offset_day(7*(items[i]["views"]-lastSeries))
			
			var date2 = classDate.new()
			date2.set_equal(date)
			date2.offset_day(7)
			for s in range(transferDate.size()):
				if(transferDate[s]["series"] == items[i]["views"] +1):
					date2.set_equal(transferDate[s]["date"])
					break
			var date3 = classDate.new()
			date3.set_equal(date2)
			date3.offset_day(7)
							
			if(date.compare(currentDay) || (date.less(currentDay) && date2.more(currentDay))):
				color = green #зеленый если нет серий для просмотра
			elif(date.more(currentDay)):
				color = Color(1,0,1)
			else:
				color = red #красный если есть серии для просмотра
			get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, color) #изменение цвета элемента	
		
	else:
		if items[i]["views"]: #просмотренно
			get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, blue) #изменение цвета элемента
########################## END ##################################

########################## Работа с массивов элементов ##################
#сохранение элемента при его редактировании
func _on_EditDialog_confirmed(): 
	if(add_new_item):
		#print("add")
		var ID = items.size()
		var addItem = get_node("EditDialog").get_data()
		addItem["ID"] = ID
		items.push_back(addItem)
		count_item = items.size()
		create_list()
	else:
		#print(get_node("EditDialog").get_data())
		var ID = items[current_item[select_item]]["ID"]
		var newItem = get_node("EditDialog").get_data()
		newItem["ID"] = items[current_item[select_item]]["ID"]
		items[current_item[select_item]] = newItem
		create_list()
		_on_ItemList_item_selected(select_item)
	file_is_save = false

#даты перенесенных серий
func _on_transfer_pressed(): 
	if(!get_node("TransferDialog").is_visible()):
		if(select_item != -1):
			get_node("TransferDialog/series").set_max(items[current_item[select_item]]["series"])
			get_node("TransferDialog").set_data(items[current_item[select_item]]["transfer"])
		get_node("TransferDialog").show()
	else:
		get_node("TransferDialog").hide()

#добавление переноса серий
func _on_TransferDialog_confirmed():
	items[current_item[select_item]]["transfer"] = get_node("TransferDialog").get_data()
	file_is_save = false
	
#добавление нового элемента !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
func _on_add_new_item_pressed(): 
	#var newDate = classDate.new()
	add_new_item = true
	get_node("EditDialog").set_title("Добавить новый элемент")
	#get_node("EditDialog").set_data(newItem)
	get_node("EditDialog").show()
	file_is_save = false
	
#редактирование элемента
func _on_edit_pressed(): 
	if(select_item != -1):
		add_new_item = false
		get_node("EditDialog").set_title("Редактировать элемент")
		get_node("EditDialog").set_data(items[current_item[select_item]])
		get_node("EditDialog").show()
	else:
		_on_add_new_item_pressed()
	file_is_save = false
########################## END ##################################

	
########################## Настройки Сортировки и Показа списка ############
#переключение поиска
func _on_sorting_toggled( pressed ): 
	sorting = pressed
	if(pressed):
		get_node("TabContainer/sortingSetting/Panel/sort_local").show()
	else:
		get_node("TabContainer/sortingSetting/Panel/sort_local").hide()
	create_list()

#поиск оригинальное название, локальное название
func _on_sort_local_toggled( pressed ): 
	sort_local = pressed
	create_list()

#показать просмотренные
func _on_viewed_toggled( pressed ): 
	viewed = pressed
	create_list()

#показать в просмотре
func _on_onview_toggled( pressed ): 
	onview = pressed
	create_list()

#показать неначатые
func _on_notstarted_toggled( pressed ): 
	notstarted = pressed
	create_list()

#показывать многосерийные
func _on_serial_toggled( pressed ):
	serialView = pressed
	create_list()

#показывать односерийные
func _on_movie_toggled( pressed ):
	movieView = pressed
	create_list()

#показывать игры
func _on_game_toggled( pressed ):
	gameView = pressed
	create_list()

#показать однотомники
func _on_book_toggled( pressed ):
	bookView = pressed
	create_list()

#показать многотомники
func _on_manga_toggled( pressed ):
	mangaView = pressed
	create_list()

#показывать только интересное
func _on_interest_toggled( pressed ):
	interestView = pressed
	create_list()
########################## END ##################################


########################## Удаление элемента #########################
#вызов диалога удаления элемента
func _on_item_delete_pressed():
	get_node("DeleteDialog/name_orig").set_text(items[current_item[select_item]]["name_orig"])
	get_node("DeleteDialog/name_local").set_text(items[current_item[select_item]]["name_local"])
	get_node("DeleteDialog").show()

#удаление элемента
func _on_DeleteDialog_confirmed(): 
	count_item = count_item - 1
	items.remove(current_item[select_item])
	select_item = -1
	for i in range(count_item):
		items[i]["ID"] = i
	create_list()
	file_is_save = false
########################## END ##################################


########################## Диалог выхода из программы ##################
#диалог выхода, сохранение файла
func _on_save_pressed(): 
	if count_item <= 0: #если ничего нет, просто выходим
		save_conf()
		get_tree().quit()
	elif file_path == "": #если файл новый показывает окно сохранения
		get_node("QuitDialog").hide()
		get_node("FileDialog").set_mode(FileDialog.MODE_SAVE_FILE)
		get_node("FileDialog").show()
	else: #для перезаписи существующего файла
		#print("save")
		save_file(file_path)
		save_conf()
		get_tree().quit()

#диалог выхода, без сохранения файла
func _on_notSave_pressed():
	save_conf()
	get_tree().quit()

#диалог выхода, отмена выхода
func _on_cancelQuit_pressed():
	get_node("QuitDialog").hide()
########################## END ##################################


########################## Редактирование просмотра и важности записи ########
#Влючение важности записи
func _on_interestView_toggled( pressed ):
	items[current_item[select_item]]["interest"] = pressed
	create_list()
	file_is_save = false

#просмотрено, только для movie, game и book
func _on_views_toggled( pressed ):
	if items[current_item[select_item]]["type"] == "movie" or items[current_item[select_item]]["type"] == "game" or items[current_item[select_item]]["type"] == "book":
		items[current_item[select_item]]["views"] = pressed
	create_list()
	file_is_save = false
	
#изменение количества просмотренных серий только для serial и manga
func _on_views_value_changed( value ): 
	if items[ current_item[select_item] ]["type"] == "serial" or items[ current_item[select_item] ]["type"] == "manga":
		if(old_item == select_item):
			items[current_item[select_item]]["views"] = int(value)
			create_list()
			file_is_save = false
########################## END ##################################

	
########################## Работа с буфером обмена ОС ##################
#копирование названия в буфер обмена "название серия"
func _on_copy_orig_pressed():
	if select_item != -1:
		var copyToBuffer = items[current_item[select_item]]["name_orig"]
		if items[current_item[select_item]]["type"] == "serial" or items[current_item[select_item]]["type"] == "manga":
			if copySeries:
				copyToBuffer += str(" ", items[current_item[select_item]]["views"] + 1)
		if items[current_item[select_item]]["type"] == "serial" or items[current_item[select_item]]["type"] == "movie":
			if copyWord:
				copyToBuffer += str(" ", add_word)
		print(copyToBuffer)
		OS.set_clipboard(copyToBuffer)

func _on_copy_local_pressed():
	if select_item != -1:
		var copyToBuffer = items[current_item[select_item]]["name_local"]
		if items[current_item[select_item]]["type"] == "serial" or items[current_item[select_item]]["type"] == "manga":
			if copySeries:
				copyToBuffer += str(" ", items[current_item[select_item]]["views"] + 1)
		if items[current_item[select_item]]["type"] == "serial" or items[current_item[select_item]]["type"] == "movie":
			if copyWord:
				copyToBuffer += str(" ", add_word)
		print(copyToBuffer)
		OS.set_clipboard(copyToBuffer)
########################## END ##################################


########################## Диалог сохранения файла при создании нового #######
func _on_saveOld_createNew_pressed():
	get_node("newFile").hide()
	save_file(file_path)
	file_path = ""
	OS.set_window_title("AnimeList")
	clear_list()
	create_list()
	
func _on_notSaveOld_createNew_pressed():
	get_node("newFile").hide()
	file_path = ""
	OS.set_window_title("AnimeList")
	clear_list()
	create_list()

func _on_cancelCreateNew_pressed():
	get_node("newFile").hide()
########################## END ##################################


