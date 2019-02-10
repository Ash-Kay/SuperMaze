extends Node

var hint_count = 5
var music_state = true
var sfx_state = true
var BGMusic
var music_path = ["res://Audio/Airglow.ogg",
"res://Audio/Cepheid.ogg","res://Audio/Comet Halley.ogg",
"res://Audio/Eternity (Reprise).ogg","res://Audio/Eternity.ogg",
"res://Audio/In Time.ogg","res://Audio/Light Years.ogg",
"res://Audio/Messier 45.ogg","res://Audio/Red Giant.ogg",
"res://Audio/Ultra Deep Field.ogg"]

func _ready():
	randomize()
	
	BGMusic = load("res://Scene/BGMusic.tscn").instance()
	add_child(BGMusic)
	
	play_rand_music()

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
	#emmit to sfx source
	sfx_state = !state
	print("GM sfx : "+String(sfx_state))

func _on_music_finished():
	play_rand_music()

func play_rand_music():
	BGMusic.stream = load(music_path[ randi() % music_path.size() ])
	BGMusic.playing = true
