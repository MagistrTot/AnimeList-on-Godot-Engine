#скрипт класс для работы с датами

#get_date() - возвращает дату в формате {"day":1, "month":1, "year":2000}
#get_text() - возвращает дату строкой вида "1 Января 20016"
#get_weekday() - возвращает день недели строкой вида "Понедельник"
#get_text_num() - возвращает дату строкой вида "1/1/2016"
#get_max_day() - возвращает максимальное количество дней в месяце (учитывается и високосный год)
#set_date_from_text(separator, data, sequence) - устанавливает дату из строки data, с разделителем separator (по умолчанию "/"), 
# вида sequence (по умолчанию "dmy", или "mdy",  т е "день месяц год" или "месяц день год")
#set_equal(data) - устанавливает дату равным data = classDate.new(), объявленным ранее в скрипте родителе
#set_date(day,month,year) - устанавливает дату по входящим данным
#set_current_date() - устанавливает дату текущим днем в операционной системе
#is_leap_year() - проверка на високосный год, возвращает true - если год високосный, иначе - false 
#offset_day(day) - смещение даты на количество дней (day)
#
#входящий параметр data это объявленный ранее в скрипте родителе (data = classDate.new())
#compare(data) - сравнивание строк, true - если равны, false - если не равны
#less(data) - сравнивание строк, true - если меньше data, иначе - false
#more(data) - сравнивание строк, true -если больше data, иначе -false

extends Node
var date = {"day":1, "month":1, "year":2000}
var leap_year
var month_day
#месяцы начинаются с 1
#var months = ["Unknown","January","February","March","April","May","June","July","August","September","October","November","December"]
var months = ["Unknown","Января","Февраля","Марта","Апреля","Мая","Июня","Июля","Августа","Сентября","Октября","Ноября","Декабря"]
var countDays = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
#дни недели начинаются с 0 - воскресенье, 7 - суббота
var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

func _ready():
	pass

func get_date():
	return date
	
func set_equal(data):
	date["day"] = data.date["day"]
	date["month"] = data.date["month"]
	date["year"] = data.date["year"]
	is_leap_year()
	correct()
	
func set_date(day = 1, month= 1, year=2000):
	date["day"] = day
	date["month"] = month
	date["year"] = year
	is_leap_year()
	correct()

func get_weekday():
	var a = (14 - date["month"])/12
	var y = date["year"] - a
	var m = date["month"] + 12*a - 2
	var weekday = (7000 + (date["day"] + y + y/4 - y/100 + y/400 + (31*m)/12)) % 7
	return days[weekday]
	
func get_text():
	return str(date["day"], " ", months[date["month"]], " ", date["year"])
	
func get_text_num():
	return str(date["day"],"/",date["month"],"/",date["year"])

func set_current_date():
	var newDate = OS.get_date()
	date["day"] = newDate["day"]
	date["month"] = newDate["month"]
	date["year"] = newDate["year"]
	return newDate
	
func is_leap_year():
	if(date["year"]%4 == 0 && date["year"]%100 != 0 || date["year"]%400 == 0):
		leap_year = true
	else:
		leap_year = false
	return leap_year
	
func get_max_day():
	is_leap_year()
	if(date["month"] == 2):
		if(leap_year):
			return 29
		else:
			return 28
	else:
		return countDays[date["month"]]

func correct():
	is_leap_year()
	if(date["month"] == 2):
		if(leap_year):
			if(date["day"] >= 29):
				date["day"] = 29
		else:
			if(date["day"] >= 28):
				date["day"] = 28
	else:
		if(date["day"] >= countDays[date["month"]]):
			date["day"] = countDays[date["month"]]
	
func set_date_from_text(separator = "/", data = "01/01/2000", sequence = "dmy"):
	var pos = data.find(separator, 0)
	var end_pos = data.find_last(separator)
	if(sequence == "dmy"): #при записит ДД-ММ-ГГГГ
		date["day"] = int(data.substr(0, pos))
		date["month"] = int(data.substr(pos+1, end_pos-pos-1))
		date["year"] = int(data.substr(end_pos+1,data.length()-end_pos))
	elif(sequence == "mdy"):#при записи ММ-ДД-ГГГГ
		date["month"] = int(data.substr(0, pos))
		date["day"] = int(data.substr(pos+1, end_pos-pos-1))
		date["year"] = int(data.substr(end_pos+1,data.length()-end_pos))
	is_leap_year()
	correct()
	
func offset_day(offset = 1):
	offset = int(offset)
	var old_day = date["day"]
	var new_day = old_day + offset
	if(offset > 0):
		daysmonth(date["month"])
		while(new_day > month_day):
			date["month"] += 1
			new_day -= month_day
			if(date["month"] > 12):
				date["month"] = 1
				date["year"] += 1
			daysmonth(date["month"])
	if(offset < 0):
		daysmonth(date["month"]-1)
		while(new_day < 0):
			date["month"] -= 1
			new_day = month_day + new_day
			if(date["month"] < 1):
				date["month"] = 12
				date["year"] -= 1
			daysmonth(date["month"])
	date["day"] = new_day
	#print(date)
	
func daysmonth(month = 1):
	if(month == 2):
		if(leap_year):
			month_day = 29
		else:
			month_day = 28
	else:
		month_day = countDays[month]
		
func compare(data = date):
	if(date["year"] == data.date["year"]):
		if(date["month"] == data.date["month"]):
			if(date["day"] == data.date["day"]):
				return true
			else:
				return false
		else:
			return false
	else:
		return false
		
func more(data = date):
	if(date["year"] > data.date["year"]):
		return true
	elif(date["year"] == data.date["year"]):
		if(date["month"] > data.date["month"]):
			return true
		elif(date["month"] == data.date["month"]):
			if(date["day"] > data.date["day"]):
				return true
			else:
				return false
		else:
			return false
	else:
		return false
	
func less(data = date):
	if(date["year"] < data.date["year"]):
		return true
	elif(date["year"] == data.date["year"]):
		if(date["month"] < data.date["month"]):
			return true
		elif(date["month"] == data.date["month"]):
			if(date["day"] < data.date["day"]):
				return true
			else:
				return false
		else:
			return false
	else:
		return false