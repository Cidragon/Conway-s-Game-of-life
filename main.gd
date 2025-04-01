extends Node2D

@onready var tiles: TileMapLayer = %tiles
@onready var background: Sprite2D = %background
@onready var generation: Label = %generation
@onready var camera_2d: Camera2D = %Camera2D
@onready var timer: Timer = %Timer

var generation_counter : int = 0
var initial_background_scale : Vector2i = Vector2i(144, 81)

var r_pentomino_size : Vector2i = Vector2(144*2 + 2,81*2 + 4)
var r_pentomino_points = [Vector2i(148,80), Vector2i(149, 79), Vector2i(149, 80), Vector2i(149, 81), Vector2i(150, 79)]

var world : Array = []

enum TILE_STATE {
	DEAD,
	ALIVE
}

func _ready() -> void:
	background.scale = r_pentomino_size
	generation.text = "Generation: " + str(generation_counter)
	camera_2d.position.y += 2 * 8
	start_shape()
	paint_points()

func start_shape() -> void:
	for y in range(r_pentomino_size.y):
		world.append([])
		for x in range(r_pentomino_size.x):
			world[y].append(0)
	
	for point in r_pentomino_points:
		world[point.y][point.x] = 1



func calculate_gen() -> void:
	var next_generation : Array = world.duplicate(true)

	for y in range(world.size()):
		for x in range(world[y].size()):
			var neighbours : int = 0
			if (y-1 >= 0) and (x-1 >= 0) and world[y-1][x-1] == TILE_STATE.ALIVE:
				neighbours += 1
			if (y-1 >= 0) and world[y-1][x] == TILE_STATE.ALIVE:
				neighbours += 1
			if (y-1 >= 0) and (x+1 < world[y].size()) and world[y-1][x+1] == TILE_STATE.ALIVE:
				neighbours += 1
			if (x-1 >= 0) and world[y][x-1] == TILE_STATE.ALIVE:
				neighbours += 1
			if (x+1 < world[y].size()) and world[y][x+1] == TILE_STATE.ALIVE:
				neighbours += 1
			if (y+1 < world.size()) and (x-1 < world[y].size()) and world[y+1][x-1] == TILE_STATE.ALIVE:
				neighbours += 1
			if (y+1 < world.size()) and world[y+1][x] == TILE_STATE.ALIVE:
				neighbours += 1
			if (y+1 < world.size()) and (x+1 < world[y].size()) and world[y+1][x+1] == TILE_STATE.ALIVE:
				neighbours += 1
			
			#change alive tiles to dead ones
			if world[y][x] == 1 and (neighbours < 2 or neighbours > 3):
				next_generation[y][x] = 0
			
			#change dead tiles to alive ones
			if world[y][x] == 0 and neighbours == 3:
				next_generation[y][x] = 1
	
	world = next_generation

func delete_borders() -> void:
	for x in range(world[0].size()):
		world[0][x] = 0
		world[1][x] = 0
		world[world.size()-2][x] = 0
		world[world.size()-1][x] = 0
	
	for y in range(world.size()):
		world[y][0] = 0
		world[y][1] = 0
		world[y][world[y].size() - 2] = 0
		world[y][world[y].size() - 1] = 0

func paint_points() -> void:
	tiles.clear()
	for y in range(world.size()):
		for x in range(world[y].size()):
			if world[y][x] == 1:
				tiles.set_cell(Vector2i(x,y), 0, Vector2(0,0))
	pass

func _on_timer_timeout() -> void:
	generation_counter += 1
	generation.text = "Generation: " + str(generation_counter)
	calculate_gen()
	#delete_borders()
	paint_points()
	


func _on_start_button_up() -> void:
	timer.start()
