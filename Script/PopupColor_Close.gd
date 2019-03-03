extends Popup

export(String) var alpha = "be"
onready var border = $Border
onready var inner = get_node("Border/MarginContainer/Inner")

func _ready():
	set_ui_color()

func set_ui_color():
	border.color = Color(alpha+GameManager.light_color)
	inner.color = Color(alpha+GameManager.dark_color)

func _on_CloseButton_pressed():
	self.hide()
