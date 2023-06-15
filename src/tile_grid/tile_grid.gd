@tool
class_name TileGrid
extends TileMap

## This class handles the grid functions for manipulating TileMaps and TileCells.
##
## TileGrid uses Cartesian plane coordinates.
## TileGrid uses Manhatten distance, so all cost are either 0 or 1.
## Usage of "tile" and "tiles" in variables / methods will refer to Vector2i Cartesian coordinates.
## Usage of "cell" and "cells" in variables / methods will refer to TileCells.
## Usage of "cost" refers to integar values used for movement costs.

# const GRID_WIDTH: int = 3
# const GRID_HEIGHT: int = 3

const LAYER_GROUND: int = 0
const ATLAS_SOURCE_ID: int = 0

# const VECTOR2I_ZERO: Vector2i = Vector2i.ZERO
const EMPTY_TILE: Vector2i = Vector2i(-1, -1)

# Define the tile size and offset (center) position of our tiles.
const TILE_WIDTH: int = 128
const TILE_HEIGHT: int = 64
const TILE_SIZE: Vector2i = Vector2i(TILE_WIDTH, TILE_HEIGHT)
const TILE_OFFSET: Vector2 = Vector2(0, (TILE_SIZE.y / 2))

# Directions of cardinal tiles, clockwise from midnight
const DIR_N: Vector2i = Vector2i.UP
const DIR_E: Vector2i = Vector2i.RIGHT
const DIR_S: Vector2i = Vector2i.DOWN
const DIR_W: Vector2i = Vector2i.LEFT
const CARDINAL: Array[Vector2i] = [DIR_N, DIR_E, DIR_S, DIR_W]

# Grid used to store all TileCells.
# Allows easy retrieval of TileCells from the dictionary.
# {Vector2: TileCell}
var grid: Dictionary # Holds all TileCell data

## Should this be focused.
@export var focus: bool = false

# Properties used to ensure only valid locations are used to create the grid and cells.
# Many of these are likely unneeded, but I'm a fan of forward preparedness.
@onready var _bounds: Rect2 = get_used_rect()
@onready var _origin_x: int = _bounds.position.x
@onready var _origin_y: int = _bounds.position.y
@onready var _width: int = _bounds.end.x
@onready var _height: int = _bounds.end.y
@onready var _origins: Vector2i = Vector2i(_origin_x, _origin_y)
@onready var _size: Vector2i = Vector2i(_width, _height)


func _ready() -> void:
	print("Ready: ", self.name)
	return


func _set_Map() -> void:
	# Should be called last.
	# Sends all the info created to the Singleton Map.
	Map.bounds = _bounds
	Map.origin_x = _origin_x
	Map.origin_y = _origin_y
	Map.width = _width
	Map.height = _height
	Map.origins = _origins
	Map.size = _size
	Map.grid = grid
	Map.map = self
	return


func _get_id_for_point(point : Vector2i) -> int:
	# Creates IDs used for AStar information.
	var x: int = point.x - _origin_x
	var y: int = point.y - _origin_y
	return int(x + y * _bounds.size.x)


func _get_cell_rect(pos: Vector2) -> PackedVector2Array:
	# Get rect from a TileCell's center position.
	# Creates the diamond-shaped rectangle polygon of our tile cells.
	# TODO: Find a better/simpler/prettier way of doing this?
	var vertex_n: Vector2 = Vector2(pos.x, (pos.y + (TILE_HEIGHT / 2)))
	var vertex_e: Vector2 = Vector2(pos.x + (TILE_WIDTH / 2), pos.y)
	var vertex_s: Vector2 = Vector2(pos.x, (pos.y - (TILE_HEIGHT / 2)))
	var vertex_w: Vector2 = Vector2(pos.x - (TILE_WIDTH / 2), pos.y)
	var rect: PackedVector2Array = PackedVector2Array([vertex_n, vertex_e, vertex_s, vertex_w]) 
	return rect


func _init_tile_grid() -> void:
	# Creates our grid dictionary.
	# Adds all information inside each TileCell instance.
	# TODO: Look into validating the cell has a tile.
	# TODO: Or ensure we 'wall' spaces.
	var cell_list: Array[Vector2i] = get_used_cells(LAYER_GROUND)

	for cell in cell_list:
		var coordinates: Vector2i = cell
		# print("<coordinates: ", coordinates, ">")
		var center: Vector2 = map_to_local(coordinates)
		# print("<center: ", center, ">")
		var rect: PackedVector2Array = _get_cell_rect(center)
		# print("rect: ", rect)
		var id = _get_id_for_point(coordinates)
		grid[cell] = TileCell.new(coordinates, center, id, rect)
	return


func set_TileGrid() -> void:
	y_sort_enabled = true
	set_layer_y_sort_enabled(LAYER_GROUND, true)
	_init_tile_grid()
	_set_Map()
	print_stats()
	print("TileGrid initiated.")
	return


func print_stats() -> void:
	print("grid position: ", position)
	print("grid origins: ", _origins)
	print("grid bounds: ", _bounds)
	print("grid size: ", _size)
	return
