extends Node

var GameScene
var SettingPopup

onready var UInode = $UI
onready var BG = $BG

func _ready():
	GameScene = "res://Scene/Game.tscn"
	SettingPopup = get_node("UI/Popup")
	set_MainMenu_color()

func set_MainMenu_color():
	UInode.modulate = Color(GameManager.light_color)
	BG.modulate = Color(GameManager.dark_color)

func _on_play_pressed():
	get_tree().change_scene(GameScene)

func _on_settings_pressed():
	SettingPopup.popup()

func _on_music_toggled(button_pressed):
	GameManager.set_music_state(button_pressed)

func _on_SFX_toggled(button_pressed):
	GameManager.set_sfx_state(button_pressed)
