extends AudioStreamPlayer

func _ready():
	self.connect("finished", get_parent(), "_on_music_finished")

