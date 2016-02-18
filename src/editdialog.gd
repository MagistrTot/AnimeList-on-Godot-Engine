#даилог редактирования/добавления сериала
extends ConfirmationDialog

var classDate = preload("res://classDate.gd")
var months = ["Unknown","Января","Февраля","Марта","Апреля","Мая","Июня","Июля","Августа","Сентября","Октября","Ноября","Декабря"]
var editDate
var item

func _ready():
	editDate = classDate.new()
	for i in range(1,13):
		get_node("month").add_item(months[i],i)
	get_node("complete").add_item("Выходит", 1)
	get_node("complete").add_item("Завершен", 2)
	get_node("complete").add_item("Ожидается", 3)
	
func set_data(editItem):
	item = editItem
	editDate = editItem["reliese"]
	get_node("year").set_value(editDate.date["year"])
	get_node("month").select(editDate.date["month"]-1)
	get_node("day").set_max(editDate.get_max_day())
	get_node("day").set_value(editDate.date["day"])
	get_node("name_orig").set_text(editItem["name_orig"])
	get_node("name_local").set_text(editItem["name_local"])
	get_node("series").set_value(editItem["series"])
	get_node("views").set_max(item["series"])
	get_node("views").set_value(editItem["views"])
	if(editItem["complete"] == "Yes"):
		get_node("complete").select(1)
	elif(editItem["complete"] == "No"):
		get_node("complete").select(0)
	else:
		get_node("complete").select(2)

func get_data():
	if(get_node("complete").get_selected_ID() == 1):
		item["compete"] = "No"
	elif(get_node("complete").get_selected_ID() == 2):
		item["compete"] = "Yes"
	elif(get_node("complete").get_selected_ID() == 3):
		item["compete"] = "New"
	item["name_orig"] = get_node("name_orig").get_text()
	item["name_local"] = get_node("name_local").get_text()
	item["series"] = int(get_node("series").get_value())
	item["views"] = int(get_node("views").get_value())
	item["reliese"] = editDate
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
	get_node("views").set_max(value)
