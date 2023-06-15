extends Camera2D

@export_range(0, 10, 0.01) var sensitivity : float = 3
@export_range(0, 1000, 0.1) var default_velocity : float = 5
@export_range(0, 10, 0.01) var speed_scale : float = 1.17
@export_range(1, 100, 0.1) var boost_speed_multiplier : float = 3.0
@export var max_speed : float = 1000
@export var min_speed : float = 0.2

var view_position: Vector2
var view_rect: Rect2
var view_size: Vector2
var view_width_half: int = view_size.x / 2
var view_height_half: int = view_size.y / 2

var map_size: Vector2
var map_tile_size: Vector2
var map_tile_width_half: int
var map_tile_height_half: int

# Add the height of the UI Hud so we can scroll to the bottom of the map.
# Without this the UI Hud blocks the map.
# Look into dynamically adding this through a signal.
var ui_hud_height: int = 200

var drag: bool = false
var ui_drag: String = "ui_drag"

@onready var _velocity = default_velocity


func _ready() -> void:
	_init_camera()
	set_as_top_level(true)
	set_process(true)
	Relay.Cursor_previous_tile_coordinates.connect(_on_Cursor_previous_tile_coordinates)
	Players.turn_start_coordinates.connect(_on_Player_turn_start_coordinates)
	return


func _physics_process(_delta: float) -> void:
	if drag:
		position = get_global_mouse_position()
	return


func _input(event: InputEvent) -> void:
	# Mouse in viewport coordinates.

	if event is InputEventMouseButton and event.is_pressed():
		if event.is_action(ui_drag):
			drag = true
		if event.is_action_released(ui_drag):
			drag = false
	return


func _init_camera() -> void:
	map_size = Map.size
	map_tile_size = Map.TILE_SIZE
	map_tile_width_half = map_tile_size.x / 2
	map_tile_height_half = map_tile_size.y / 2

	limit_top = 0
	limit_right = map_size.x * map_tile_size.x
	# limit_bottom = ((map_size.y + map_size.x) * map_tile_height_half) + ui_hud_height
	limit_bottom = (map_size.y * map_tile_height_half) + ui_hud_height
	# limit_left = - map_size.x * map_tile_width_half
	limit_left = 0
	return


func _on_Cursor_previous_tile_coordinates(_pos: Vector2) -> void:
	position = _pos
	return


func _on_Player_turn_start_coordinates(_coords: Vector2) -> void:
	# Focus camera on current active player's unit.
	position = Map.get_map_position(_coords)
	return
