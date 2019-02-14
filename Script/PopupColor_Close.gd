extends Popup

onready var border = $Border
onready var inner = get_node("Border/MarginContainer/Inner")

func _ready():
	set_ui_color()

func set_ui_color():
	border.color = Color("be"+GameManager.light_color)
	inner.color = Color("be"+GameManager.dark_color)

func _on_CloseButton_pressed():
	self.hide()
