extends Node

var GameScene
var SettingPopup

func _ready():
	GameScene = "res://Scene/Game.tscn"
	SettingPopup = get_node("UI/Popup")

func _on_play_pressed():
	get_tree().change_scene(GameScene)

func _on_settings_pressed():
	SettingPopup.popup()
