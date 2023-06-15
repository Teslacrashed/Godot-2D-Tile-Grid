extends TileMap

const LAYER_GROUND: int = 0
const ATLAS_SOURCE_ID: int = 0

# const VECTOR2I_ZERO: Vector2i = Vector2i.ZERO
const EMPTY_TILE: Vector2i = Vector2i(-1, -1)

# Define the tile size and offset (center) position of our tiles.
const TILE_WIDTH: int = 128
const TILE_HEIGHT: int = 64
const TILE_SIZE: Vector2i = Vector2i(TILE_WIDTH, TILE_HEIGHT)
const TILE_OFFSET: Vector2 = Vector2(0.0, (TILE_SIZE.y / 2))

# Directions of cardinal tiles, clockwise from midnight
const DIR_N: Vector2i = Vector2i.UP
const DIR_E: Vector2i = Vector2i.RIGHT
const DIR_S: Vector2i = Vector2i.DOWN
const DIR_W: Vector2i = Vector2i.LEFT
const CARDINAL: Array[Vector2i] = [DIR_N, DIR_E, DIR_S, DIR_W]

var tile_selected: TileCell
var unit_selected: Unit

var _movement_cells: Array[Vector2i]:
	set(new_cells):
		if new_cells != _movement_cells:

			_movement_cells = new_cells

			var tiles: Array[TileCell] = []
			for cell in _movement_cells:
				var new_tile = Map.get_tile_at(cell)
				tiles.append(new_tile)

			_movement_tiles = tiles
		return

var _movement_tiles: Array[TileCell]:
	set(new_movement_tiles):
		if new_movement_tiles != _movement_tiles:
			_movement_tiles = new_movement_tiles
			Relay.BattleMap_movement_tiles.emit(_movement_tiles)
		return

# Grid used to store all TileCells.
# Allows easy retrieval of TileCells from the dictionary.
# {Vector2: TileCell}
var grid: Dictionary  # Holds all TileCell data

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
	# Build the current grid from our TileGrid class.
	# fabricate_grid then sends this information to the Map singleton.

	Relay.Cursor_tile_selected.connect(_on_Cursor_tile_selected)
	Relay.Cursor_unit_selected.connect(_on_Cursor_unit_selected)

	_init_tile_cells()
	_init_map()

	print("Ready: ", self.name)
	return


func _unhandled_input(_event: InputEvent) -> void:
	# Add the tile's map position of approximately where the mouse cursor if pointing at.
	if Input.is_action_just_pressed("ui_cancel"):
		# Clear selection variables and return cursor state to MOVE.
		# _clear_cache()
		pass
	return


func _init_tile_cells() -> void:
	# Creates our grid dictionary.
	# Adds all information inside each TileCell instance.
	# TODO: Look into validating the cell has a tile.
	# TODO: Or ensure we 'wall' spaces.
	var cell_list: Array[Vector2i] = get_used_cells(LAYER_GROUND)

	for cell in cell_list:
		var coordinates: Vector2i = cell
		var center: Vector2 = map_to_local(coordinates)
		# print("<center: ", center, ">")
		var rect: PackedVector2Array = _get_cell_rect(center)
		# print("rect: ", rect)
		var id = _convert_from_coordinates_to_id(coordinates)
		grid[cell] = TileCell.new(coordinates, center, id, rect)

	# This is done after the creation of all cells in the grid.
	# Easiest way to ensure all neighbors are valid cells.
	for tile in grid.values():
		_set_tile_neighbor_tiles(tile)

	return


func _init_map() -> void:
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

func _clear_selected() -> void:
	tile_selected = null
	unit_selected = null
	return

func _convert_from_coordinates_to_id(point : Vector2i) -> int:
	# Creates IDs used for AStar information.
	var x: int = point.x - _origin_x
	var y: int = point.y - _origin_y
	var rv: int = int(x + y * _bounds.size.x)
	return rv


func _flood_fill(tile: TileCell, max_distance: int) -> Array[Vector2i]:
	# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
	var cells: Array[Vector2i] = []
	var start: Vector2i = tile.coordinates
	var stack: Array[Vector2i] = [start]

	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()

		if not Map.is_within_bounds(current):
			continue

		if current in cells:
			continue

		var distance: int = Map.manhattan_distance(current, start)

		if distance > max_distance:
			continue

		cells.append(current)

		for direction in CARDINAL:
			var coordinates: Vector2i = current + direction

			if not Map.is_within_bounds(coordinates):
				continue

			if cells.has(coordinates):
				continue

			var current_tile = Map.get_tile_at(coordinates)
			if current_tile and current_tile.unit:
				var current_unit = current_tile.unit

			stack.append(coordinates)

	return cells


func _is_valid_map_cell(cell: Vector2i) -> bool:
	# Ensures coordinates are valid.
	# First see if the coordinate point exist in the TileMap's used Rect2.
	# Second check if the coordinates exist in the location of TileMap's used tiles.
	var rv: bool = _bounds.has_point(cell) and cell in get_used_cells(LAYER_GROUND)
	return rv


func _find_attackable_tiles(tile: TileCell):
	# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
	# Players can only control one unit, so any occupied cell is attackable.
	# In other projects check for if unit is a player unit.
	var attackable_tiles: Array[TileCell] = []

	# TODO: Change to opening neighbors to save some useless checks.
	for neighbor in tile.neighbors:

		# if not Map.is_within_bounds(coordinates):
		#	continue
		if neighbor.is_occupied:
			attackable_tiles.append(neighbor)

	return attackable_tiles


func _get_cell_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	# Returns all adjacent tiles in the cardinal directions.
	var cells: Array[Vector2i] = []
	for dir in CARDINAL:
		cells.append(cell + dir)
	return cells


func _set_tile_neighbor_tiles(tile: TileCell) -> void:
	# Adds the neighboring TileCells to every cell in our grid.
	var tiles: Array[TileCell] = []
	for dir in _get_cell_adjacent_cells(tile.coordinates):
		if _is_valid_map_cell(dir):
			tiles.append(grid[dir])
	tile.neighbors = tiles
	return


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


func get_movement_cells(tile: TileCell) -> Array[Vector2i]:
	# Returns an array of tiless a given unit can walk using the flood fill algorithm.
	var movement_distance: int = unit_selected.movement_points
	return _flood_fill(tile, movement_distance)


func _on_Cursor_tile_selected(tile: TileCell) -> void:
	# Receives signal from Battle class.
	tile_selected = tile
	return


func _on_Cursor_unit_selected(unit: Unit) -> void:
	# Receives signal from Battle class.
	unit_selected = unit
	if unit_selected:
		_movement_cells = get_movement_cells(tile_selected)
	else:
		_movement_cells = []
	return

