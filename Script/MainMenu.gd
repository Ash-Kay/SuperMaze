extends Node

var gameScene

func _ready():
	gameScene = "res://Scene/Main.tscn"


func _on_Button_button_down():
	get_tree().change_scene(gameScene)
