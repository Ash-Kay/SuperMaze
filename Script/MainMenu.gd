extends Node

var GameScene
var SettingPopup

onready var UInode = $UI
onready var BG = $BG
onready var PauseMenuBorder = get_node("UI/Popup/Border")
onready var PauseMenuInner = get_node("UI/Popup/Border/MarginContainer/Inner")
onready var MusicButton = get_node("UI/Popup/MarginContainer/VBoxContainer/HBoxContainer/Music")
onready var SFXButton = get_node("UI/Popup/MarginContainer/VBoxContainer/HBoxContainer/SFX")

func _ready():
	get_tree().set_quit_on_go_back(true)
	GameScene = "res://Scene/Game.tscn"
	SettingPopup = get_node("UI/Popup")
	set_MainMenu_color()
	set_sound_state()

func set_MainMenu_color():
	UInode.modulate = Color(GameManager.light_color)
	BG.modulate = Color(GameManager.dark_color)
	
	PauseMenuInner.color = Color("be"+GameManager.dark_color)
	PauseMenuBorder.color = Color("be"+GameManager.light_color)

#++++++++++++++++++++++++ SIGNALS +++++++++++++++++++++++++++++++

func _on_play_pressed():
	get_tree().change_scene(GameScene)

func _on_settings_pressed():
	SettingPopup.popup()

func _on_music_toggled(button_pressed):
	GameManager.set_music_state(button_pressed)

func _on_SFX_toggled(button_pressed):
	GameManager.set_sfx_state(button_pressed)

#+++++++++++++++++++++++++ OTHERS +++++++++++++++++++++++++++++++++++
func set_sound_state():
	MusicButton.pressed = !GameManager.music_state
	SFXButton.pressed = !GameManager.sfx_state


