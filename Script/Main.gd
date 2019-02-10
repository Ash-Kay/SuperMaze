extends Node

export(float) var x_margin = 0
export(float) var y_margin = 0
var y_top_offset = 128

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 64  # tile size (in pixels)
var width = 30  # width of map (in tiles)
var height = 40  # height of map (in tiles)
var scr_size

var move_sfx
var maze_colors

var curr_touch_grid = Vector2(0, 0)
var base_touch_pos
var curr_touch_pos

var line_points = []
var cool_down_timer
var can_draw = true #can draw after shot interval of time (timer)

# maze start and end points
var start_point
var end_point

# get a reference of Nodes used
onready var Map = $TileMap
onready var Line = $Line2D
onready var SolveLine = $SolvedPath
onready var BG = $BG
onready var HintCount = get_node("GameGUI/MarginContainer/VBoxContainer/HBoxContainer/HintCount")
onready var PauseMenu = get_node("GameGUI/PauseMenu")
onready var PlayPauseButton = get_node("GameGUI/MarginContainer/VBoxContainer/HBoxContainer/PlayPause")

#+++++++++++++++++++++++++ READY AND PROCESS +++++++++++++++++++++++++

func _ready():
	randomize()
	
	cool_down_timer = Timer.new()
	cool_down_timer.set_one_shot(true)
	cool_down_timer.set_wait_time(0.05)
	cool_down_timer.connect("timeout", self, "on_timeout_complete")
	add_child(cool_down_timer)
	
	move_sfx = $Move
	
	#print(OS.window_size)
	tile_size = Map.cell_size
	
	if OS.get_name() != "Windows":
		scr_size = OS.window_size
	else:
		scr_size = Vector2(1080,1920)#for TEST ONLY
	
	width = floor((scr_size.x - 2 * x_margin) / tile_size.x)
	height = floor((scr_size.y - 2 * y_margin - y_top_offset) / tile_size.y)
	
	#print(String(width)+" "+String(height))
	#centre the map
	x_margin += (scr_size.x - width*tile_size.x)
	Map.position = Vector2(x_margin/2 , y_margin/2 + y_top_offset)
	
	print("maze width: "+ String(width*tile_size.x) + "  screen width: "+
	 String(scr_size.x) + "  remainin: "+ String(scr_size.x - width*tile_size.x) +
	"  margin: "+String(x_margin)+" "+String(y_margin) )
	
	maze_colors = [{"tile": "60e1ff", "bg": "212b3b", "name": "darkblue"},
			{"tile": "6cffe6", "bg": "083339", "name": "green"},
			{"tile": "d48e8e", "bg": "3d0707", "name": "darkred"},
			{"tile": "ff1d77", "bg": "2c051b", "name": "pink"},
			{"tile": "ff971d", "bg": "1a2c05", "name": "yellowgreen"},
			{"tile": "0000ad", "bg": "05052c", "name": "voilet"}]
	
	RELOAD()

func _process(delta):
	touch_input()

#+++++++++++++++++++++++++ LOADER AND MODULATE +++++++++++++++++++++++++

func RELOAD():
	make_maze()
	reset_endpoint()
	change_color()

func change_color():
	var color = maze_colors[ randi() % maze_colors.size() ]
#	var color = maze_colors[3]
	BG.modulate = Color(color["bg"])
	Map.modulate = Color(color["tile"])

#+++++++++++++++++++++++++ MAZE GENRATION +++++++++++++++++++++++++

func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			Map.set_cellv(current, current_walls)
			Map.set_cellv(next, next_walls)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		#yield(get_tree(), "idle_frame")

func reset_endpoint():
	set_end_points()
	curr_touch_grid = start_point
	Line.set_points([])
	line_points.clear()
	Line.add_point(grid_to_pixel(start_point))
	line_points.append(start_point)
	clear_solve_line()
	find_solution(start_point)

func set_end_points():
	var end_holder = get_node("EndHolder")

	for c in end_holder.get_children():
		c.queue_free()
	
	start_point = Vector2(randi() % int(width), randi() % int(height))
	end_point = Vector2(randi() % int(width), randi() % int(height))
	
	var point_scene = load("res://Scene/EndPoint.tscn")
	
	var start_point_sprite = point_scene.instance()
	start_point_sprite.name = "StartPoint"
	start_point_sprite.position = grid_to_pixel(start_point)
	start_point_sprite.modulate = Color(1,1,1)
	
	var end_point_sprite = point_scene.instance()
	end_point_sprite.name = "EndPoint"
	end_point_sprite.position = grid_to_pixel(end_point)
	end_point_sprite.modulate = Color(0,1,0)
	
	end_holder.add_child(start_point_sprite)
	end_holder.add_child(end_point_sprite)

#+++++++++++++++++++++++++ MAZE SOLVING +++++++++++++++++++

func find_solution(start):
	var q = []
	var tracker = {}
	var curr
	var unvisited = []
	var reached = false
	q.append(start)
	
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
	
	while q and !reached:
		curr = q.front()
		for n in cell_walls.keys():
			if (curr + n) in unvisited and can_move(curr + n, curr):
				q.append(curr + n)
				tracker[curr + n] = curr
				unvisited.erase(curr + n)
				if curr+n == end_point:
					reached = true
		q.pop_front()
	backtracker(tracker, start)

func backtracker(dic, start):
	var curr = dic[end_point]
	
	while curr != start:
		SolveLine.add_point(grid_to_pixel(curr))
		curr = dic[curr]
	
	print(SolveLine.get_point_count())
	if SolveLine.get_point_count() < 150 and start == start_point:
		reset_endpoint()
	else:
		var solve_points = SolveLine.get_points()
		var solve_points_short = []
		SolveLine.visible = false
		for i in range(solve_points.size()-1, solve_points.size()-21, -1):
			solve_points_short.append(solve_points[i])
		SolveLine.set_points(solve_points_short)

func clear_solve_line():
	SolveLine.set_points([])

#+++++++++++++++++++++++++ HELPER +++++++++++++++++++++++++

func pixel_to_grid(pixel_cord):
	var new_x = floor((pixel_cord.x - x_margin)/tile_size.x)
	var new_y = floor((pixel_cord.y - y_margin - y_top_offset)/tile_size.y)
	#print(String(new_x) + " " + String(new_y))
	return Vector2(new_x, new_y)

func grid_to_pixel(grid_cord):
	var new_x = x_margin/2 + grid_cord.x * tile_size.x + tile_size.x/2
	var new_y = y_margin/2 + y_top_offset + grid_cord.y * tile_size.y + tile_size.y/2
	#print("pg: "+String(new_x) + " " + String(new_y))
	return Vector2(new_x, new_y)

func can_move(ctg, ptg):
	if(cell_walls.has(ctg - ptg)):
		#check if valid move
		var dir = ptg - ctg
		if(Map.get_cellv(ctg) & cell_walls[dir]):
			#print("*Cant move")
			return false
		else:
			return true
	return false

func on_timeout_complete():
	can_draw = true

#+++++++++++++++++++++++++ TOUCH MANAGE +++++++++++++++++++++++++

func touch_input():
	if Input.is_action_just_pressed("ui_click") and get_viewport().get_mouse_position().y > y_top_offset:
		 base_touch_pos = get_viewport().get_mouse_position()
		
	if Input.is_action_pressed("ui_click") and can_draw and get_viewport().get_mouse_position().y > y_top_offset:
		if get_swipe_norm(curr_touch_grid):
			curr_touch_grid +=  get_swipe_norm(curr_touch_grid)
			draw_line()
			#print("point added: "+ String(curr_touch_grid))
		can_draw = false
		cool_down_timer.start()

func draw_line():
	#if go back remove line point
	if(line_points.size() >= 2 and curr_touch_grid == line_points[line_points.size()-2]):
		Line.remove_point(line_points.size()-1)
		line_points.pop_back()
	else:
		Line.add_point(grid_to_pixel(curr_touch_grid))
		line_points.append(curr_touch_grid)
		if GameManager.sfx_state:
			move_sfx.play()
		
	if curr_touch_grid == end_point:
		RELOAD()

func get_swipe_dir():
	curr_touch_pos = get_viewport().get_mouse_position()
	var dir = Vector2 (0, 0)
	if curr_touch_pos != base_touch_pos :
		dir = curr_touch_pos - base_touch_pos
		if abs(dir.x) > abs(dir.y) :
			dir.y = 0
			if dir.x > 0 :
				dir.x = 1
			else:
				dir.x = -1
		else:
			dir.x = 0
			if dir.y > 0 :
				dir.y = 1
			else:
				dir.y = -1
	#print(dir)
	return dir

func get_swipe_norm(ctg):
	curr_touch_pos = get_viewport().get_mouse_position()
	var dir = Vector2 (0, 0)
	
	if(curr_touch_pos != base_touch_pos):
		dir = curr_touch_pos - base_touch_pos
		dir = dir.normalized()
		
		if abs(dir.x)> abs(dir.y):
			if can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
				#print(Vector2(round(dir.x),0))
				return Vector2(round(dir.x),0)
			elif abs(dir.y) > 0.1 and can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
				#print(Vector2(0,round(dir.y)))
				return Vector2(0,round(dir.y))
		else:
			if can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
				#print(Vector2(0,round(dir.y)))
				return Vector2(0,round(dir.y))
			elif abs(dir.x) > 0.1 and can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
				#print(Vector2(round(dir.x),0))
				return Vector2(round(dir.x),0)
	return false

func _on_solve_pressed():
	if GameManager.hint_count > 0:
		clear_solve_line()
		find_solution(curr_touch_grid)
		SolveLine.visible = true
		GameManager.use_hint()
		GameManager.update_hint_ui(HintCount)

func _on_PlayPause_pressed():
	PauseMenu.popup()

func _on_PauseMenu_popup_hide():
	PlayPauseButton.pressed = false
