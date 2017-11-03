#диалог редактирования/добавления сериала
extends ConfirmationDialog

var classDate = preload("res://classDate.gd")
var months = ["Unknown","Января","Февраля","Марта","Апреля","Мая","Июня","Июля","Августа","Сентября","Октября","Ноября","Декабря"]
var editDate
var item

func _ready():
	editDate = classDate.new()
	for i in range(1,13):
		get_node("month").add_item(months[i],i)
	
func set_data(editItem):
	editDate = editItem["reliese"]
	if editItem["type"] == "serial" or editItem["type"] == "manga":
		get_node("many").show()
		get_node("one").hide()
		if editItem["type"] == "serial": # serial == 0
			get_node("type").set_selected(0)
		elif editItem["type"] == "manga": # manga == 3
			get_node("type").set_selected(3)
		get_node("year").set_value(editDate.date["year"])
		get_node("month").select(editDate.date["month"]-1)
		get_node("day").set_max(editDate.get_max_day())
		get_node("day").set_value(editDate.date["day"])
		get_node("name_orig").set_text(editItem["name_orig"])
		get_node("name_local").set_text(editItem["name_local"])
		get_node("many/views").set_max(editItem["series"])
		get_node("many/series").set_value(editItem["series"])
		get_node("many/views").set_value(editItem["views"])
		get_node("interestView").set_pressed(editItem["interest"])
	elif editItem["type"] == "movie" or editItem["type"] == "game" or editItem["type"] == "book" :
		get_node("many").hide()
		get_node("one").show()
		if editItem["type"] == "movie":# movie == 1
			get_node("type").set_selected(1)
		elif editItem["type"] == "game": # game == 2
			get_node("type").set_selected(2)
		elif editItem["type"] == "book":# book == 4
			get_node("type").set_selected(4)
		get_node("year").set_value(editDate.date["year"])
		get_node("month").select(editDate.date["month"]-1)
		get_node("day").set_max(editDate.get_max_day())
		get_node("day").set_value(editDate.date["day"])
		get_node("name_orig").set_text(editItem["name_orig"])
		get_node("name_local").set_text(editItem["name_local"])
		get_node("one/views").set_pressed(editItem["views"])
		get_node("interestView").set_pressed(editItem["interest"])

func get_data():
	if get_node("type").get_selected() == 0 or get_node("type").get_selected() == 3: #serial == 0 or manga == 3
		var type = "serial"
		if get_node("type").get_selected() == 3:
			type = "manga"
		item= {"ID":-1, "type":type, 
						"name_orig":get_node("name_orig").get_text(), 
						"name_local":get_node("name_local").get_text(), 
						"series":int(get_node("many/series").get_value()), 
						"views":int(get_node("many/views").get_value()), 
						"reliese": editDate, 
						"transfer":"", 
						"interest":get_node("interestView").is_pressed()}
	elif get_node("type").get_selected() == 1 or get_node("type").get_selected() == 2 or get_node("type").get_selected() == 4:# movie == 1 or game == 2 or book == 4
		var type = "movie"
		if get_node("type").get_selected() == 2:
			type = "game"
		elif get_node("type").get_selected() == 4:
			type = "book"
		item= {"ID":-1, "type":type, 
						"name_orig":get_node("name_orig").get_text(), 
						"name_local":get_node("name_local").get_text(), 
						"views":get_node("one/views").is_pressed(), 
						"reliese": editDate, 
						"interest":get_node("interestView").is_pressed()}
	return item

func _on_month_item_selected( ID ):
	editDate.date["month"] = get_node("month").get_selected_ID()
	get_node("day").set_max(editDate.get_max_day())
	editDate.correct()
	get_node("day").set_value(editDate.date["day"])

func _on_day_value_changed( value ):
	editDate.date["day"] = int(value)

func _on_year_value_changed( value ):
	editDate.date["year"] = int(value)
	get_node("day").set_max(editDate.get_max_day())
	editDate.correct()
	get_node("day").set_value(editDate.date["day"])

func _on_series_value_changed( value ):
	get_node("many/views").set_max(value)

func _on_curentDate_pressed():
	var curentDate = OS.get_date()
	get_node("year").set_value(curentDate.year)
	get_node("month").select(curentDate.month - 1)
	get_node("day").set_value(curentDate.day)


func _on_type_button_selected( button_idx ):
	if button_idx == 0 or button_idx == 3:
		get_node("many").show()
		get_node("one").hide()
	else:
		get_node("many").hide()
		get_node("one").show()
		
