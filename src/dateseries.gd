#скрипт для показа релизов серий в правой колонке

extends ItemList

var classDate = preload("res://classDate.gd")
var startday = classDate.new()
var transferDate = []
var allDate = false
var currentData = ""
var data #здесь будет ссылка на просматриваемый элемент
var date = classDate.new()
var currentDay = classDate.new()

func _ready():
	pass

func set_series(dataSrc): #загружаем данные
	data = dataSrc
	currentDay.set_current_date()
	startday.set_equal(data["reliese"]) #дата релиза первой серии
	date.set_equal(startday)
	transferDate.clear()
	if(data["transfer"].length() > 0): #внесение дат релизов серий
		var str1 = data["transfer"].split(":",false)
		for i in range(str1.size()):
			var str2 = str1[i].split("-",false)
			var trDate = classDate.new()
			trDate.set_date_from_text("/",str2[1],"dmy")
			var addItem = {"series":int(str2[0]),"date":trDate}
			transferDate.push_back(addItem)
	create()

func create(): # создание списка серий для показа
	get_node(".").clear()
	date.set_equal(startday)
		
	if(data["complete"] != "Yes" && !allDate): #показать серии которые еще не вышли
		date.set_equal(startday)
		for t in range(data["series"]):
			if(transferDate.size() > 0):
				for s in range(transferDate.size()):
					if(transferDate[s]["series"] == t+1):
						date.set_equal(transferDate[s]["date"])
			if(t+1 > data["views"]):
				get_node(".").add_item(str(t+1,":",date.get_text()))
			date.offset_day(7)
	elif(allDate): #показать все серии
		date.set_equal(startday)
		for t in range(data["series"]):
			if(transferDate.size() > 0):
				for s in range(transferDate.size()):
					if(transferDate[s]["series"] == t+1):
						date.set_equal(transferDate[s]["date"])
			get_node(".").add_item(str(t+1,":",date.get_text()))
			date.offset_day(7)
	else:
		add_item("Все вышли")
	
	if(startday.less(currentDay) && date.more(currentDay)): #если сериал еще выходит
		data["complete"] = "No"
	elif(startday.more(currentDay)): #если показ сериала не начался
		data["complete"] = "New"
	elif(date.less(currentDay)): # если все серии вышли
		data["complete"] = "Yes"
		

func _on_allDate_toggled( pressed ): #показывать ли все серии
	allDate = pressed
	create()