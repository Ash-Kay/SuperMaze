extends Node

export(float) var x_margin = 0
export(float) var y_margin = 0

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 64  # tile size (in pixels)
var width = 30  # width of map (in tiles)
var height = 40  # height of map (in tiles)
var scr_size = OS.window_size

var curr_touch_grid = Vector2(0, 0)
#var prev_touch_grid = Vector2(-1, 0)
var base_touch_pos = Vector2(1080/2, 1920/2)
var curr_touch_pos

var line_points = []
var cool_down_timer
var can_draw = true

# get a reference to the map for convenience
onready var Map = $TileMap
onready var Line = $Line2D

#+++++++++++++++++++++++++ READY AND PROCESS +++++++++++++++++++++++++

func _ready():
	randomize()
	
	cool_down_timer = Timer.new()
	cool_down_timer.set_one_shot(true)
	cool_down_timer.set_wait_time(0.05)
	cool_down_timer.connect("timeout", self, "on_timeout_complete")
	add_child(cool_down_timer)
	
	#print(OS.window_size)
	tile_size = Map.cell_size
	
	width = floor((1080 - 2 * x_margin) / tile_size.x)
	height = floor((1920 - 2 * y_margin) / tile_size.y)
	
	#print(String(width)+" "+String(height))
	#centre the map
	Map.position = Vector2(x_margin/2, y_margin/2)
	make_maze()
	
	Line.add_point(grid_to_pixel(curr_touch_grid))
	line_points.append(curr_touch_grid)

func _process(delta):
	touch_input()

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
		
	#set first and last open
	Map.set_cellv( Vector2(0, 0), Map.get_cellv(Vector2(0, 0)) - W)
	Map.set_cellv( Vector2(width-1, height-1), Map.get_cellv(Vector2(width-1, height-1)) - E)

#+++++++++++++++++++++++++ HELPER +++++++++++++++++++++++++

func pixel_to_grid(pixel_cord):
	var new_x = floor((pixel_cord.x - x_margin)/tile_size.x)
	var new_y = floor((pixel_cord.y - y_margin)/tile_size.y)
	#print(String(new_x) + " " + String(new_y))
	return Vector2(new_x, new_y)

func grid_to_pixel(grid_cord):
	var new_x = x_margin/2 + grid_cord.x * tile_size.x + tile_size.x/2
	var new_y = y_margin/2 + grid_cord.y * tile_size.y + tile_size.y/2
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
	if Input.is_action_just_pressed("ui_click"):
		 base_touch_pos = get_viewport().get_mouse_position()
		
	if Input.is_action_pressed("ui_click") and can_draw:
#		if(can_move(curr_touch_grid + get_swipe_dir(), curr_touch_grid)):
#			curr_touch_grid +=  get_swipe_dir()
#			#print(curr_touch_grid)
#			draw_line()
#			get_swipe_norm(curr_touch_grid)
		curr_touch_grid +=  get_swipe_norm(curr_touch_grid)
		#draw_line()
		print("point added: "+ String(curr_touch_grid))
		can_draw = false
		cool_down_timer.start()

func draw_line():
	#if go back remove line point
	if(line_points.size() > 2 and curr_touch_grid == line_points[line_points.size()-2]):
		Line.remove_point(line_points.size()-1)
		line_points.pop_back()
	else:
		Line.add_point(grid_to_pixel(curr_touch_grid))
		line_points.append(curr_touch_grid)

func get_swipe_dir():
	curr_touch_pos = get_viewport().get_mouse_position()
	var dir = Vector2 (0, 0)
	if(curr_touch_pos != base_touch_pos):
		dir = curr_touch_pos - base_touch_pos
		if(abs(dir.x)> abs(dir.y)):
			dir.y = 0
			if(dir.x > 0):
				dir.x = 1
			else:
				dir.x = -1
		else:
			dir.x = 0
			if(dir.y > 0):
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
		#print("dir: "+String(dir))
		
		if abs(dir.x)> abs(dir.y):
			if can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
				print(Vector2(round(dir.x),0))
				return Vector2(round(dir.x),0)
			elif abs(dir.y) > 0.4 and can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
				print(Vector2(0,round(dir.y)))
				return Vector2(0,round(dir.y))
		else:
			if can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
				print(Vector2(0,round(dir.y)))
				return Vector2(0,round(dir.y))
			elif abs(dir.x) > 0.4 and can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
				print(Vector2(round(dir.x),0))
				return Vector2(round(dir.x),0)
#
#		if abs(dir.x)> abs(dir.y):
#			if can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
#				print(Vector2(ctg.x + round(dir.x),0))
#				return Vector2(ctg.x + round(dir.x),0)
#			elif abs(dir.y) > 0.5 and can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
#				return Vector2(0, ctg.y + round(dir.y))
#		else:
#			if can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
#				print(Vector2(ctg.x, ctg.y + round(dir.y)), ctg)
#				return Vector2(0, ctg.y + round(dir.y))
#			elif abs(dir.x) > 0.5 and can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
#				return Vector2(ctg.x + round(dir.x),0)
		
#		if abs(dir.x)> abs(dir.y) and can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
#			print("case1")
#			return Vector2(ctg.x + round(dir.x),0)
#
#			if abs(dir.y) > 0.5 and can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
#				print("case2")
#				return Vector2(0, ctg.y + round(dir.y))
#
#		if abs(dir.y)> abs(dir.x) and can_move(Vector2(ctg.x, ctg.y + round(dir.y)), ctg):
#			print("case3")
#			return Vector2(0, ctg.y + round(dir.y))
#
#			if abs(dir.x) > 0.5 and can_move(Vector2(ctg.x + round(dir.x), ctg.y), ctg):
#				print("case4")
#				return Vector2(ctg.x + round(dir.x),0)
			
			
	#print("ctg: "+String(ctg))
	return Vector2(0, 0)