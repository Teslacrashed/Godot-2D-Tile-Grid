extends Node2D
## Represents a grid with its size, the size of each cell in pixels, and some helper functions to
## calculate and convert coordinates.
## It's meant to be shared between game objects that need access to those values.

# Define the tile size and offset (center) position of our tiles.
const TILE_WIDTH: int = 128
const TILE_HEIGHT: int = 64
const TILE_SIZE: Vector2i = Vector2i(TILE_WIDTH, TILE_HEIGHT)
const TILE_OFFSET: Vector2 = Vector2(0, (TILE_HEIGHT / 2))

# Directions of cardinal tiles, clockwise from midnight.
const DIR_N: Vector2i = Vector2i.UP
const DIR_E: Vector2i = Vector2i.RIGHT
const DIR_S: Vector2i = Vector2i.DOWN
const DIR_W: Vector2i = Vector2i.LEFT
const CARDINAL: Array[Vector2i] = [DIR_N, DIR_E, DIR_S, DIR_W]

# Get TileGrid class so we can use map_to_world and world_to_map.
# TODO: Find more elegant way of doing this.
var map: TileMap

# Properties recieved from the TileGrid class.
# Many are likely unneeded.
var bounds: Rect2
var origin_x: int
var origin_y: int
var width: int
var height: int
var origins: Vector2
var size: Vector2

# Dictionary recieved from TileGrid class allows easy retrieval of TileCells.
# {Vector2i: TileCell}
var grid: Dictionary


func print_battle_map_info() -> void:
	print("grid origins: ", origins)
	print("grid bounds: ", bounds)
	print("grid bounds.position.x: ", bounds.position.x)
	print("grid bounds.position.y: ", bounds.position.y)
	print("grid bounds.end.x: ", bounds.end.x)
	print("grid bounds.end.x: ", bounds.end.x)
	print("grid size: ", size)
	return


func get_tile_at(cell: Vector2i) -> TileCell:
	# Returns a TileCell from the given Vector2i location on the Cartesian grid.
	if grid.has(cell):
		return grid[cell]
	else:
		return null


func get_adjacent_cells(cell: Vector2i) -> PackedVector2Array:
	# Returns Cartesian coordinates of all adjacent tiles in the cardinal directions.
	var cells: PackedVector2Array = []
	for dir in CARDINAL:
		var adj_cell: Vector2i = cell + dir
		if is_within_bounds(adj_cell):
			cells.append(adj_cell)
	return cells


func map_to_local(cell: Vector2i) -> Vector2:
	## Returns the world position of a given grid coordinate.
	var rv: Vector2 = map.map_to_local(cell)
	return rv


func local_to_map(pos: Vector2) -> Vector2i:
	## Returns the grid coordinates of a given world position.
	var rv = map.local_to_map(pos)
	return rv


func is_within_bounds(cell: Vector2i) -> bool:
	# Returns true if the grid coordinates are within the TileGrid bounds.
	var bounded_x: bool = cell.x >= 0 and cell.x < size.x
	var bounded_y: bool = cell.y >= 0 and cell.y < size.y
	var rv: bool = bounded_x and bounded_y
	return rv


func clamp_to_grid(cell: Vector2i) -> Vector2i:
	# Forces grid coordinates to fit within the grid's bounds.
	var rv: Vector2i = cell
	rv.x = clamp(rv.x, 0, (size.x - 1))
	rv.y = clamp(rv.y, 0, (size.y - 1))
	return rv


func manhattan_distance(cell_start: Vector2i, cell_end: Vector2i) -> int:
	var diff: Vector2i = (cell_end - cell_start).abs()
	var rv: int = int(diff.x + diff.y)
	return rv
