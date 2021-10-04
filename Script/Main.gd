extends Node

export(float) var x_start = 0.0
export(float) var y_start = 0.0

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
var curr_touch_pos = Vector2(0, 0)
var prev_touch_pos = Vector2(-1, 0)
var line_points = []

# get a reference to the map for convenience
onready var Map = $TileMap
onready var Line = $Line2D

func _ready():
	randomize()
	print(OS.window_size)
	tile_size = Map.cell_size
	
	width = floor(1080 / tile_size.x)
	height = floor(1920 / tile_size.y)
	
	print(String(width)+" "+String(height))
	
	make_maze()

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
		
		#set first open
		Map.set_cellv( Vector2(0, 0), Map.get_cellv(Vector2(0, 0)) - 8)

func pixel_to_grid(pixel_cord):
	var new_x = floor((pixel_cord.x - x_start)/tile_size.x)
	var new_y = floor((pixel_cord.y - y_start)/tile_size.y)
	#print(String(new_x) + " " + String(new_y))
	return Vector2(new_x, new_y)

func grid_to_pixel(grid_cord):
	var new_x = x_start + grid_cord.x * tile_size.x + tile_size.x/2
	var new_y = y_start + grid_cord.y * tile_size.y + tile_size.y/2
	#print(String(new_x) + " " + String(new_y))
	return Vector2(new_x, new_y)

func touch_input():
	if Input.is_action_pressed("ui_click"):
		curr_touch_pos = pixel_to_grid(get_viewport().get_mouse_position())
		draw_line(curr_touch_pos)
		#print("point added at: "+ String(grid_to_pixel(curr_touch_pos)))
		#pixel_to_grid(get_global_mouse_position())

func draw_line(curr_touch_pos):
	if(line_points.size()>2 and curr_touch_pos == line_points[line_points.size()-2]):
		Line.remove_point(line_points.size()-1)
		line_points.pop_back()
	
	if(cell_walls.has(curr_touch_pos - prev_touch_pos)):
		#check if valid move
		var dir = prev_touch_pos - curr_touch_pos
		if(Map.get_cellv(curr_touch_pos) & cell_walls[dir]):
			print("*Cant move")
			return
		
		prev_touch_pos = curr_touch_pos
		Line.add_point(grid_to_pixel(curr_touch_pos))
		line_points.append(curr_touch_pos)
		print("point added at: "+ String(grid_to_pixel(curr_touch_pos)))

func _process(delta):
	touch_input()
