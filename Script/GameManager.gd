extends Node

var hint_count = 5

func _ready():
	
	pass

func hint_inc(amt):
	hint_count += amt

func use_hint():
	if hint_count > 0: 
		hint_count -= 1

func update_hint_ui(label):
	label.text = String(hint_count)