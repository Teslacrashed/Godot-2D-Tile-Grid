class_name TileCell
extends Resource

## # Class manages information for tiles on our tilemaps.
##
## Initialized by the TileGrid class.
## Then filled with scene-specific information.
##
## @coordinates:
##    The grid coordinates of the TileCell.

# The strict size and offset (center) position of the TileCells.
const TILE_WIDTH: int = 128
const TILE_HEIGHT: int = 64
const TILE_SIZE: Vector2i = Vector2i(TILE_WIDTH, TILE_HEIGHT)
const OFFSET: Vector2 = Vector2(0.0, (TILE_SIZE.y / 2))

# Directions of Cartesian cardinal locations, clockwise from midnight.
const DIR_N: Vector2i = Vector2i.UP
const DIR_E: Vector2i = Vector2i.RIGHT
const DIR_S: Vector2i = Vector2i.DOWN
const DIR_W: Vector2i = Vector2i.LEFT
const CARDINAL: Array[Vector2i] = [DIR_N, DIR_E, DIR_S, DIR_W]

# The properties of TileCells.
# TODO: Update for Godot 4:
# enum CELL_TYPES{EMPTY = -1, ACTIVE, OBSTACLE, ITEM, END}
# export(CELL_TYPES) var type = CELL_TYPES.ACTIVE

# Add the center of the TileCell for placing objects and moving them.
# Most projects make a func in the TileMap class for this.
# I think this is more elegant and requires less typing.
# TileGrid class generates the proper center position and sends it here.
var center: Vector2

# The Cartesian coordinates for the TileCell.
var coordinates: Vector2i

# ID used for AStar pathfinding.
# Starts at 0 in upper-left corner, incrementing across then downward.
var id: int

# Adds the neighbor cells in the cardinal directions.
var neighbors: Array[TileCell]

# The rect2 area of a TileCell.
# Used for _draw methods to highlight cells.
var rect: PackedVector2Array

var chest
var shrine

var unit: Unit:
	set(value):
		# Add unit to cell location.
		unit = value
		if unit:
			unit.coordinates = coordinates
			unit.position = center
		return

var is_occupied: bool:
	get:
		var rv: bool = false
		if chest or shrine or unit:
			rv = true
		return rv


func _init( _coordinates: Vector2i, _center: Vector2, _id: int, _rect: PackedVector2Array) -> void:
	# Create our TileCell.
	# The 'neighbors' and 'units' are to be set by other classes.
	coordinates = _coordinates
	center = _center
	id = _id
	neighbors = []
	rect = _rect
	return


