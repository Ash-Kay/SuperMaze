extends Node

var GameScene = "res://Scene/Game.tscn"

onready var UInode = $UI
onready var BG = $BG
onready var SettingPopup = get_node("UI/Settings")
onready var CreditsPopup = get_node("UI/Credits")
onready var DailyRewards = get_node("UI/DailyRewards")
onready var MusicButton = get_node("UI/Settings/MarginContainer/VBoxContainer/SoundButtons/Music")
onready var SFXButton = get_node("UI/Settings/MarginContainer/VBoxContainer/SoundButtons/SFX")

func _ready():
	get_tree().set_quit_on_go_back(true)
	set_MainMenu_color()
	set_sound_state()
	

func set_MainMenu_color():
	UInode.modulate = Color(GameManager.light_color)
	BG.modulate = Color(GameManager.dark_color)
	

#++++++++++++++++++++++++ SIGNALS +++++++++++++++++++++++++++++++

func _on_play_pressed():
	get_tree().change_scene(GameScene)

func _on_settings_pressed():
	SettingPopup.popup()

func _on_music_toggled(button_pressed):
	GameManager.set_music_state(button_pressed)

func _on_SFX_toggled(button_pressed):
	GameManager.set_sfx_state(button_pressed)

func _on_Credits_pressed():
	CreditsPopup.popup()

#+++++++++++++++++++++++++ OTHERS +++++++++++++++++++++++++++++++++++

func set_sound_state():
	MusicButton.pressed = !GameManager.music_state
	SFXButton.pressed = !GameManager.sfx_state

func check_daily_popup():
	var amt = GameManager.check_daily_reward()
	if amt >= 0:
		DailyRewards.show()
		var label = get_node("UI/DailyRewards/MarginContainer/VBoxContainer/Value/Label")
		label.text = "+"+String(amt)


