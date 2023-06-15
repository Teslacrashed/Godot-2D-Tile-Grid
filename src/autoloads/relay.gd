extends Node

# Cursor signals.
signal Cursor_ready(bit: bool)                # {bit: bool}
signal Cursor_cell(cell)                      # {cell: Vector2i}
signal Cursor_tile(tile)                      # {tile: TileCell}
signal Cursor_unit(unit)                      # {unit: Unit}
signal Cursor_tile_selected(tile)             # {tile: TileCell}
signal Cursor_unit_selected(unit)             # {unit: Unit}
signal Cursor_previous_tile_coordinates(pos)  # {pos: Vector2} of World Coordinates
signal Cursor_unit_selected_move_tile(tile)   # {cell: TileCell}

# BattleMap signals
signal BattleMap_movement_tiles(tiles)     # {tiles: Array[TileCell]}
signal BattleMap_movement_rects(rects)     # {rects: PackedVector2Array} 
signal BattleMap_attackable_tiles(tiles)   # {tiles: Array[TileCell}
