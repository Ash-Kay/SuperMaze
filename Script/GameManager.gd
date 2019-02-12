extends Node

var hint_count = 5
var music_state = true
var sfx_state = true
var BGMusic
var light_color
var dark_color

var save_data = {"hint": 5}
var config_data = {"firstrun": true}

var save_game_file = File.new()
var config_file = ConfigFile.new()

const SAVE_PATH = "user://savegame.bin"
const CONFIG_PATH = "user://settings.cfg"
var KEY

var music_path = [	"res://Audio/Airglow.ogg",
					"res://Audio/CepheKEY.ogg","res://Audio/Comet Halley.ogg",
					"res://Audio/Eternity (Reprise).ogg","res://Audio/Eternity.ogg",
					"res://Audio/In Time.ogg","res://Audio/Light Years.ogg",
					"res://Audio/Messier 45.ogg","res://Audio/Red Giant.ogg",
					"res://Audio/Ultra Deep Field.ogg"]


var color_palette = [{"light": "60e1ff", "dark": "212b3b", "name": "darkblue"},
					{"light": "ff971d", "dark": "1a2c05", "name": "test"},
					{"light": "00cefc", "dark": "003642", "name": "blue"},
					{"light": "D1C4E9", "dark": "0e0033", "name": "lightvoilet"},
					{"light": "6cffe6", "dark": "083339", "name": "tealgreen"},
					{"light": "f73838", "dark": "300000", "name": "red"},
					{"light": "ff1d77", "dark": "2c051b", "name": "pink+marron"},
					{"light": "7171fc", "dark": "05052c", "name": "voilet"}]

func _ready():
	randomize()
	
	if OS.get_name() == "Windows":
		KEY = "123"
	else:
		KEY = OS.get_unique_id()
	
	save_game()
	check_savegame()
	
	BGMusic = load("res://Scene/BGMusic.tscn").instance()
	add_child(BGMusic)
	
	play_rand_music()
	select_palette()

func select_palette():
	var rand_color_index = randi() % color_palette.size()
	light_color =  color_palette[ rand_color_index ]["light"]
	dark_color =  color_palette[ rand_color_index ]["dark"]

#+++++++++++++++++++++++++ SAVE DATA ++++++++++++++++++++++++++++++++

func check_savegame():
	
	if not save_game_file.file_exists(SAVE_PATH):
		save_game_file.open_encrypted_with_pass(SAVE_PATH, File.WRITE, KEY)
		save_game_file.store_var(to_json(save_data))
		save_game_file.close()
	else:
		save_game_file.open_encrypted_with_pass(SAVE_PATH, File.READ, KEY)
		save_data = save_game_file.get_var()
		print( save_data )
		save_game_file.close()

func save_game():
	if save_game_file.file_exists(SAVE_PATH):
		save_game_file.open_encrypted_with_pass(SAVE_PATH, File.WRITE, KEY)
		save_game_file.store_var(to_json(save_data))
		save_game_file.close()

#++++++++++++++++++++++ GAME CONTROL AND SIGNALS +++++++++++++++++++++++++++++++

func hint_inc(amt):
	hint_count += amt

func use_hint():
	if hint_count > 0: 
		hint_count -= 1

func update_hint_ui(label):
	label.text = String(hint_count)

func set_music_state(state):
	music_state = !state
	BGMusic.playing = music_state
	
	if music_state:
		play_rand_music()
	print("GM music : "+String(music_state))

func set_sfx_state(state):
	sfx_state = !state
	print("GM sfx : "+String(sfx_state))

func _on_music_finished():
	play_rand_music()

func play_rand_music():
	BGMusic.stream = load(music_path[ randi() % music_path.size() ])
	BGMusic.playing = true
