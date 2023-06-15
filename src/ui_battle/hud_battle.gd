extends Node2D
# Handles highlighting tiles for movement and abilities.
# Gets commands from our parent Battlefield UI.
# Should be easy enough to use this as a base for drawing enemy path seperately.
# Or for painting special tiles, like obstacles or chest, differently.
# Could also be used for line of sight / fog of war mechancis.
# Might have been easier to use instances sprite nodes, but I like this way better.
# Feels easier to control the dynamics, even if messier with the passing of functions.
# Another fun idea is flags for making highlights different colors for special circumstances.

# Colors in the color pallette I'm thinking about.
const RED: Color = Color(0.75, 0.15, 0.15, 0.65)  # Enemies.
const BLUE: Color = Color(0.36, 0.43, 0.88, 0.75)  # Movement.
const VIOLET: Color = Color(0.27, 0.16, 0.23, 0.50)  # Current tile.

# For following our mouse cursor and dynamically highlight the tile/cell.
var cursor_tile: TileCell:
	set(value):
		if value != cursor_tile:
			cursor_tile = value
			if cursor_tile:
				cursor_rect = cursor_tile.rect

var cursor_rect: PackedVector2Array
var cursor_unit: Unit

var attackable_tiles: Array[TileCell]:
	set(new_attackable_tiles):
		if new_attackable_tiles != attackable_tiles:
			attackable_tiles = new_attackable_tiles

			# All possible movement tiles for the active character's unit.
			var rects: Array[PackedVector2Array] = []
			if not attackable_tiles.is_empty():
				for tile in attackable_tiles:
					if tile:
						rects.append(tile.rect)

			attackable_rects = rects
		return

var attackable_rects: Array[PackedVector2Array]

var movement_tiles: Array[TileCell]:
	set(new_movement_tiles):
		if new_movement_tiles != movement_tiles:
			movement_tiles = new_movement_tiles

			# All possible movement tiles for the active character's unit.
			var rects: Array[PackedVector2Array] = []
			if not movement_tiles.is_empty():
				for tile in movement_tiles:
					if tile:
						rects.append(tile.rect)

			movement_rects = rects
		return

var movement_rects: Array[PackedVector2Array]

var active: bool = false


func _ready() -> void:
	Relay.Cursor_ready.connect(_on_Cursor_ready)
	Relay.Cursor_tile.connect(_on_Cursor_tile)
	Relay.BattleMap_attackable_tiles.connect(_on_BattleMap_attackable_tiles)
	Relay.BattleMap_movement_tiles.connect(_on_BattleMap_movement_tiles)
	print("Ready: ", self.name)
	return


func _physics_process(_delta: float) -> void:
	if active:
		queue_redraw()
	return


func _draw() -> void:
	# This draw is for the hovered tile/rect/cell.
	if cursor_rect:
		draw_colored_polygon(cursor_rect, VIOLET)

	if movement_rects:
		# This draws on all valid tiles in a movement path.
		# can use similar logic for showing enemy paths or line of sight.
		#for _tile in _movement_tiles:
		for rect in attackable_rects:
			draw_colored_polygon(rect, RED)

	if movement_rects:
		# This draws on all valid tiles in a movement path.
		# can use similar logic for showing enemy paths or line of sight.
		#for _tile in _movement_tiles:
		for rect in movement_rects:
			draw_colored_polygon(rect, BLUE)
	return


func _on_BattleMap_attackable_tiles(tiles: Array[TileCell]) -> void:
	attackable_tiles = tiles
	return


func _on_BattleMap_movement_tiles(tiles: Array[TileCell]) -> void:
	movement_tiles = tiles
	return


func _on_Cursor_ready(bit: bool) -> void:
	active = bit
	return


func _on_Cursor_tile(tile: TileCell) -> void:
	cursor_tile = tile
	# cursor_rect = cursor_tile.rect
	return
