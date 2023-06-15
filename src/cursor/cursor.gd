@tool
extends Node2D

# We'll use signals to keep the cursor decoupled from other nodes.
# When the player moves the cursor or wants to interact with a cell, we emit a signal and let
# another node handle the interaction
signal mode_changed(mode)  # {mode: int}

# MOVE is the "default" mode for the current player to select their unit.
# MOVE_SELECT is the mode entered after unit selection, and used for selection the target tile.
# WAIT is the mode while various actions or cutscenes occur.
enum Mode {MOVE, MOVE_SELECT, ATTACK, ATTACK_SELECT, WAIT}

## Time before the cursor can move again, in seconds.
@export var timer_cooldown: float = 0.1

# Used to control what actions are valid and when.
var mode: int = Mode.MOVE:
	set(new_mode):
		if new_mode != mode:
			mode = new_mode
		return

var pos: Vector2 = Vector2.ZERO:
	set(new_pos):
		if new_pos != pos:
			pos = new_pos
		return

# Coordinates of the current tile the cursor is hovering.
var cell: Vector2i = Vector2i.ZERO:
	set(new_cell):
		# We first clamp the cell coordinates and ensure that we weren't trying to move outside the
		# grid's boundaries.
		var test_cell: Vector2i = Map.clamp_to_grid(new_cell)
		var is_within_bounds: bool = Map.is_within_bounds(test_cell)

		if test_cell != cell and is_within_bounds:
			# print('cell: ', cell)
			cell = test_cell
			Relay.Cursor_cell.emit(cell)
			tile = Map.get_tile_at(cell)
			timer.start()

		return

# Hovered variables for sending information to other components.
var tile: TileCell:
	set(new_tile):
		# Only change if cursor in a new cell's area.
		# This should avoid UI elements being constantly re-drawn later.
		if new_tile != tile:
			tile = new_tile
			Relay.Cursor_tile.emit(tile)
			if tile:
				unit = tile.unit
		return

var unit: Unit = null:
	set(new_unit):
		if new_unit != unit:
			unit = new_unit
			Relay.Cursor_unit.emit(unit)
		return

# Selected properties for gameplay actions and UI components.
var tile_selected: TileCell:
	set(value):
		if value != tile_selected:
			tile_selected = value
			Relay.Cursor_tile_selected.emit(tile_selected)
			if tile_selected and tile_selected.is_occupied:
				unit_selected = tile.unit
			else:
				unit_selected = null
		return

var unit_selected: Unit = null:
	set(new_unit):
		if new_unit != unit_selected:

			if unit_selected and not new_unit:
				unit_selected.selected = false

			unit_selected = new_unit

			if unit_selected:
				unit_selected.selected = true
			Relay.Cursor_unit_selected.emit(unit_selected)
		return

# Hold previous tile for special circumstances, like returning the camera position.
var previous_tile_coordinates:
	set(new_previous_tile_coordinates):
		if new_previous_tile_coordinates != previous_tile_coordinates:
			previous_tile_coordinates = new_previous_tile_coordinates
			Relay.Cursor_previous_tile_coordinates.emit(previous_tile_coordinates)
		return

var active: bool = false

var is_ai_turn: bool = false

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = timer_cooldown
	position = Map.map_to_local(cell)
	print("Ready: ", self.name)
	return


func _unhandled_input(event: InputEvent):
	# Add the tile's map position of approximately where the mouse cursor if pointing at.

	# Navigating cells with the mouse.
	if event is InputEventMouseMotion:
		pos = event.position
		cell = Map.local_to_map(pos)

	if not active:
		active = true
		Relay.Cursor_ready.emit(true)

	var should_move: bool = event.is_pressed()
	if event.is_echo():
		should_move = should_move and timer.is_stopped()

	if not should_move:
		return

	# Use keys to move the cursor by one tile.
	if event.is_action("ui_up"):
		cell += Vector2i.UP
	elif event.is_action("ui_right"):
		cell += Vector2i.RIGHT
	elif event.is_action("ui_down"):
		cell += Vector2i.DOWN
	elif event.is_action("ui_left"):
		cell += Vector2i.LEFT

	if Input.is_action_just_pressed("ui_cancel"):
		# Clear selection variables and return cursor state to MOVE.
		_handle_cancel()

	if Input.is_action_just_pressed("ui_accept"):

		match mode:
			Mode.MOVE:
				# Exploring the map and choosing unit to move.
				_handle_selection()
			_:
				pass
	return


func _handle_selection() -> void:
	tile_selected = tile
	previous_tile_coordinates = Map.map_to_local(tile_selected.coordinates)

	if unit_selected and mode != Mode.MOVE_SELECT:
		# Unit is selected, shift mode to next phase.
		mode = Mode.MOVE_SELECT

	return


func _handle_cancel() -> void:
	# Clears out actions.
	clear_selection()

	match mode:
		Mode.MOVE:
			print("Cursor.mode is MOVE, no change.")
			pass

		Mode.MOVE_SELECT:
			mode = Mode.MOVE

		Mode.ATTACK:
			print('Cursor.mode is ATTACK, no change.')
			pass

		Mode.ATTACK_SELECT:
			mode = Mode.ATTACK

	if previous_tile_coordinates:
		previous_tile_coordinates = null
	return


func clear_selection() -> void:
	unit_selected = null
	tile_selected = null
	return
