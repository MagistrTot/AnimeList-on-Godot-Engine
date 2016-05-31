#родительский скрипт
extends Control

var classDate = preload("res://classDate.gd") #предзагрузка нового типа данных (дата)
var items = [] #массив элементов
var count_item #количество элементов
var add_new_item = false
var viewed = true
var onview = true
var notstarted = true
var sorting = false
var sort_local = false
var add_word = ""
var last_file = "" #последний открытый файл
var select_item = -1 #текущий выбранный элемент
var old_item = -1
var sort_index = [] #массив сортировки
var current_item = [] #массив для показа
var file_path = "" #файл для открытия
var config = ConfigFile.new()


func _notification(what): #при корректном выходе из приложения сохранение параметров приложения
	if(what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_conf()

func _ready():
	#загрузка параметров приложения из файла находящегося рядом с приложением
	#если поменять res:// на user:// то файл будет грузиться из папки годота в app_data
	#при это не забыть поменять путь в фукнции save_conf()
	#чтобы узнать местонахождение папки user:// расскоментировать нижний принт
	#print(OS.get_data_dir())
	config.load("res://animelist.cfg")
	if(config.has_section("main")):
		viewed = config.get_value("main", "view")
		onview = config.get_value("main", "onview")
		notstarted = config.get_value("main", "notview")
		sorting = config.get_value("main", "sort")
		sort_local = config.get_value("main", "local")
		last_file = config.get_value("main", "path")
		add_word = config.get_value("main", "word")
		get_node("SettingDialog/word").set_text(add_word)
		if(sorting):
			get_node("config/sort_local").show()
		else:
			get_node("config/sort_local").hide()
	#настройка параметрических нодов
	get_node("config/notstarted").set_pressed(notstarted)
	get_node("config/onview").set_pressed(onview)
	get_node("config/viewed").set_pressed(viewed)
	get_node("config/sort_local").set_pressed(sort_local)
	get_node("config/sorting").set_pressed(sorting)
	
	get_node("FileDialog").set_access(2)
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
	get_node("FileMenu").get_popup().add_item("Параметры",5)
	get_node("FileMenu").get_popup().add_separator()
	get_node("FileMenu").get_popup().add_item("Выйти",6)
	#соединяем сигнал с функцией, обратить внимание на то, что сигнал "item_pressed" имеет возвращаемый параметр
	#это стандартный сигнал popupMenu item_pressed ( int ID)
	#поэтому в функции "file_item_select" должен быть входящий параметр
	get_node("FileMenu").get_popup().connect("item_pressed", self, "file_item_select")
	
	#открываем окно в центре экрана
	OS.set_window_position(Vector2(OS.get_screen_size(0).width/2-400, OS.get_screen_size(0).height/2-300))
	

func file_item_select(ID): #Выбор элемента меню
	if(ID == 6): #выход
		save_conf()
		get_tree().quit()
	elif(ID == 5): #настройки программы
		get_node("SettingDialog").show()
	elif(ID == 0): #новый файл
		file_path = ""
		clear_list()
		create_list()
	elif(ID == 1): #загрузка последнего открытого файла
		if(last_file != ""):
			load_list(last_file)
			file_path = last_file
			create_list()
	elif(ID == 2): #открыть
		get_node("FileDialog").set_mode(0)
		get_node("FileDialog").show()
	elif(ID == 3): #сохранить файл
		if(file_path == ""): #если файл новый показывает окно сохранения
			get_node("FileDialog").set_mode(3)
			get_node("FileDialog").show()
		else: #для перезаписи существующего файла
			print("save")
			save_file(file_path)
	elif(ID == 4): #сохранить как...
		get_node("FileDialog").set_mode(3)
		get_node("FileDialog").show()
	
func clear_list(): #Очистка листа элементов
	select_item = -1
	items.clear()
	
func _on_ItemList_item_selected( index ): #выбор элемента для просмотра
	if(!items.empty()):
		old_item = index
		get_node("Panel/name_orig").set_text(items[current_item[index]]["name_orig"])
		get_node("Panel/name_local").set_text(items[current_item[index]]["name_local"])
		get_node("Panel/series").set_text(str(items[current_item[index]]["series"]))
		get_node("Panel/views").set_max(float(items[current_item[index]]["series"]))
		get_node("Panel/views").set_value(float(items[current_item[index]]["views"]))
		get_node("Panel/reliese").set_text(items[current_item[index]]["reliese"].get_text())
		if(items[current_item[index]]["complete"] == "No"):
			get_node("Panel/complete").set_text("Выходит")
		elif(items[current_item[index]]["complete"] == "Yes"):
			get_node("Panel/complete").set_text("Завершен")
		elif(items[current_item[index]]["complete"] == "New"):
			get_node("Panel/complete").set_text("Ожидается")
		else:
			get_node("Panel/complete").set_text("Неизвестно")
		get_node("date_series").set_series(items[current_item[index]])
		select_item = index

func load_list(path_file): #загрузка листа
	clear_list()
	last_file = path_file
	var ID = 0
	var file_open = File.new()
	var value_data
	file_open.open(path_file,1) #представляет собой CSV файл с разделителем ";"
	"""	0 - завершенность
		1 - оригинальное название
		2 - местное название
		3 - количество серий
		4 - количество просмотренного
		5 - дата релиза
		6 - даты переноса выхода серий
	"""
	while(file_open.get_pos() < file_open.get_len()):
		var data = file_open.get_csv_line(";")
		var addDate = classDate.new()
		addDate.set_date_from_text("/", data[5], "dmy")
		var addItem = {"ID":ID, "complete":data[0], "name_orig":data[1], "name_local":data[2], "series":int(data[3]), "views":int(data[4]), "reliese": addDate, "transfer":data[6]}
		items.push_back(addItem)
		ID += 1
	count_item = items.size()
	file_open.close()
		
func create_list(): #создание нового листа элементов и сортировка по названию
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
			if(viewed && items[sort_index[i]]["series"] == items[sort_index[i]]["views"]):
				add_item(sort_index[i])
			elif(onview && items[sort_index[i]]["views"] > 0 && items[sort_index[i]]["series"] != items[sort_index[i]]["views"]):
				add_item(sort_index[i])
			elif(notstarted && items[sort_index[i]]["views"] == 0):
				add_item(sort_index[i])
		if(get_node("ItemList").get_item_count() == 0):
			get_node("ItemList").add_item("Нет Элементов для показа")
	else:
		get_node("ItemList").add_item("Нет Элементов для показа")
		
	get_node("Label").set_text(str("Количество сериалов: ", items.size(), " | Количество показанных сериалов: ", current_item.size()))

func add_item(i): #добавление элемента в список просмотра и цветовая идентификация элементов
	current_item.push_back(items[i]["ID"])
	var transferDate = []
	var date  = classDate.new()
	var currentDay = classDate.new()
	currentDay.set_current_date()
	date.set_equal(items[i]["reliese"])
	
	if(items[i]["transfer"].length() > 0):
		var str1 = items[i]["transfer"].split(":",false)
		for i in range(str1.size()):
			var str2 = str1[i].split("-",false)
			var trDate = classDate.new()
			trDate.set_date_from_text("/",str2[1],"dmy")
			var addItem = {"series":int(str2[0]),"date":trDate}
			transferDate.push_back(addItem)
	
	get_node("ItemList").add_item(str(items[i]["name_orig"],", ", items[i]["name_local"]))
	var color
	if(items[i]["series"] > items[i]["views"] && items[i]["views"] != 0): #если смотрим
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
			color = Color(0,0.2,0) #зеленый если нет серий для просмотра
		elif(date.more(currentDay)):
			color = Color(1,0,1)
		else:
			color = Color(0.2,0,0) #красный если есть серии для просмотра
		get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, color) #изменение цвета элемента
		 
	elif(items[i]["series"] <= items[i]["views"]): #синий если все серии просмотрены
		color = Color(0,0,0.2)
		get_node("ItemList").set_item_custom_bg_color(get_node("ItemList").get_item_count()-1, color) #изменение цвета элемента
	
func _on_FileDialog_OK_but(): #диалог открытия и сохранения файла
	if(get_node("FileDialog").get_mode() == 0): #открытие файла
		file_path = get_node("FileDialog").get_current_path()
		load_list(file_path)
		create_list()
	elif(get_node("FileDialog").get_mode() == 3): #сохранение файла
		save_file(get_node("FileDialog").get_current_path())

func save_file(path): #сохранение файла, если нет расширения добавляем *.list иначе сохраняем как есть
	var newFile = File.new()
	if(path.find(".list") == -1):
		newFile.open(str(path,".list"), 2)
	else:
		newFile.open(path, 2)
	for i in range(items.size()):
		var sep = ";"
		var date = items[i]["reliese"].get_text_num()
		newFile.store_line(str(items[i]["complete"],sep,items[i]["name_orig"],sep,items[i]["name_local"],sep,items[i]["series"],sep,items[i]["views"],sep,date,sep,items[i]["transfer"]))
	newFile.close()
	
func save_conf(): #сохранение файла конфигурации
	config.set_value("main", "notview", notstarted)
	config.set_value("main", "view", viewed)
	config.set_value("main", "onview", onview)
	config.set_value("main", "sort", sorting)
	config.set_value("main", "local", sort_local)
	config.set_value("main", "path", last_file)
	config.set_value("main", "word", add_word)
	config.save("res://animelist.cfg")

func _on_EditDialog_confirmed(): #сохранение элемента при его редактировании
	if(add_new_item):
		print("add")
		var ID = items.size()
		var addItem = get_node("EditDialog").get_data()
		addItem["ID"] = ID
		items.push_back(addItem)
		count_item = items.size()
		create_list()
	else:
		items[current_item[select_item]] = get_node("EditDialog").get_data()
		create_list()
		_on_ItemList_item_selected(select_item)
	
#Panel элементы
func _on_views_value_changed( value ): #изменение количества просмотренных серий
	if(old_item == select_item):
		items[current_item[select_item]]["views"] = int(value)
		create_list()

func _on_edit_pressed(): #редактирование элемента
	if(select_item != -1):
		add_new_item = false
		get_node("EditDialog").set_title("Редактировать элемент")
		get_node("EditDialog").set_data(items[current_item[select_item]])
		get_node("EditDialog").show()
	else:
		_on_add_new_item_pressed()
		
#копирование названия в буфер обмена "название серия"
func _on_copy_orig_pressed():
	OS.set_clipboard(str(items[current_item[select_item]]["name_orig"], " ", items[current_item[select_item]]["views"] + 1, " ", add_word))

func _on_copy_local_pressed():
	OS.set_clipboard(str(items[current_item[select_item]]["name_local"], " ", items[current_item[select_item]]["views"] + 1, " ", add_word))

#config элементы
func _on_transfer_pressed(): #даты перенесенных серий
	if(!get_node("TransferDialog").is_visible()):
		if(select_item != -1):
			get_node("TransferDialog/series").set_max(items[current_item[select_item]]["series"])
			get_node("TransferDialog").set_data(items[current_item[select_item]]["transfer"])
		get_node("TransferDialog").show()
	else:
		get_node("TransferDialog").hide()

func _on_TransferDialog_confirmed():
	items[current_item[select_item]]["transfer"] = get_node("TransferDialog").get_data()
	
func _on_add_new_item_pressed(): #добавление нового элемента
	print("New")
	var newDate = classDate.new()
	var newItem = {"ID":0, "complete":"No", "name_orig":"Original", "name_local":"Местное", "series":1, "views":0, "reliese": newDate, "transfer":""}
	add_new_item = true
	get_node("EditDialog").set_title("Добавить новый элемент")
	get_node("EditDialog").set_data(newItem)
	get_node("EditDialog").show()

func _on_sorting_toggled( pressed ): #переключение поиска
	sorting = pressed
	if(pressed):
		get_node("config/sort_local").show()
	else:
		get_node("config/sort_local").hide()
	create_list()

func _on_sort_local_toggled( pressed ): #поиск оригинальное название, локальное название
	sort_local = pressed
	create_list()

func _on_viewed_toggled( pressed ): #показать просмотренные
	viewed = pressed
	create_list()

func _on_onview_toggled( pressed ): #показать в просмотре
	onview = pressed
	create_list()

func _on_notstarted_toggled( pressed ): #показать неначатые
	notstarted = pressed
	create_list()


func _on_help_pressed(): #справка
	if(get_node("HelpDialog").is_visible()):
		get_node("HelpDialog").hide()
	else:
		get_node("HelpDialog").show()

func _on_item_delete_pressed():
	get_node("DeleteDialog/name_orig").set_text(items[current_item[select_item]]["name_orig"])
	get_node("DeleteDialog/name_local").set_text(items[current_item[select_item]]["name_local"])
	get_node("DeleteDialog").show()

func _on_DeleteDialog_confirmed(): #удаление элемента
	count_item = count_item - 1
	items.remove(current_item[select_item])
	select_item = -1
	for i in range(count_item):
		items[i]["ID"] = i
	create_list()

func _on_SettingDialog_confirmed(): #изменение настроек
	add_word = get_node("SettingDialog/word").get_text()
