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

func _on_music_toggled(button_pressed):
	GameManager.set_music_state(button_pressed)
	pass # replace with function body

func _on_SFX_toggled(button_pressed):
	GameManager.set_sfx_state(button_pressed)
	pass # replace with function body
