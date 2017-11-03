#диалог для добавления/редактирования перенесенных релизов серий
extends ConfirmationDialog

var classDate = preload("res://classDate.gd")
var months = ["Unknown","Января","Февраля","Марта","Апреля","Мая","Июня","Июля","Августа","Сентября","Октября","Ноября","Декабря"]
var editDate
var select = -1
# {"series":int, "date":string}
var transferDate = []

func _ready():
	editDate = classDate.new()
	get_node("day").set_max(editDate.get_max_day())
	for i in range(1,13):
		get_node("month").add_item(months[i],i)
	get_node("year").set_value(OS.get_date().year)
	get_node("month").select(OS.get_date().month-1)
	get_node("day").set_value(OS.get_date().day)
	refresh()

func set_data(string):
	transferDate.clear()
	if(string.length() > 0):
		var str1 = string.split(":",false)
		for i in range(str1.size()):
			var str2 = str1[i].split("-",false)
			var addItem = {"series":int(str2[0]),"date":str2[1]}
			transferDate.push_back(addItem)
	refresh()
	
func get_data():
	var string = ""
	for i in range(transferDate.size()):
		string = str(string, transferDate[i]["series"],"-",transferDate[i]["date"],":")
	return string

func _on_month_item_selected( ID ):
	editDate.date["month"] = get_node("month").get_selected_ID()
	get_node("day").set_max(editDate.get_max_day())
	editDate.correct()
	get_node("day").set_value(editDate.date["day"])

func _on_year_value_changed( value ):
	editDate.date["year"] = int(value)
	get_node("day").set_max(editDate.get_max_day())
	editDate.correct()
	get_node("day").set_value(editDate.date["day"])

func _on_day_value_changed( value ):
	editDate.date["day"] = int(value)

func _on_add_pressed():
	select = -1
	var string = str(int(get_node("day").get_value()),"/",get_node("month").get_selected_ID(),"/",int(get_node("year").get_value()))
	var addItem = {"series":int(get_node("series").get_value()), "date":string}
	transferDate.push_back(addItem)
	refresh()
	
func refresh():
	get_node("ItemList").clear()
	if(transferDate.size() > 0):
		for i in range(transferDate.size()):
			get_node("ItemList").add_item(str(transferDate[i]["series"],"-",transferDate[i]["date"]))
	else:
		get_node("ItemList").add_item("Нет дат")

func _on_ItemList_item_selected( index ):
	select = index
	get_node("series").set_value(transferDate[select]["series"])
	editDate.set_date_from_text("/", transferDate[select]["date"],"dmy")
	get_node("year").set_value(editDate.date["year"])
	get_node("month").select(editDate.date["month"] - 1)
	get_node("day").set_value(editDate.date["day"])

func _on_edit_pressed():
	if(select >= 0):
		var string = str(int(get_node("day").get_value()),"/",get_node("month").get_selected_ID(),"/",int(get_node("year").get_value()))
		transferDate[select]["series"] = int(get_node("series").get_value())
		transferDate[select]["date"] = string
		refresh()
