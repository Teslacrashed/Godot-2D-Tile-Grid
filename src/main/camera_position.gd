extends Marker2D

@export var LINE_LENGTH: int = 64
@export var LINE_COLOR_HEX: String = '#FFEB3B'

var active: bool = false:
	set(bit):
		active = bit
		return


func _ready() -> void:
	active = true
	return


func _physics_process(_delta: float) -> void:
	if active:
		queue_redraw()
	return


func _draw() -> void:
	var half_line_length: float = LINE_LENGTH / 2
	var color: Color = Color(LINE_COLOR_HEX)
	draw_line( Vector2(-half_line_length, 0), Vector2(half_line_length, 0), color, 3.0)
	draw_line( Vector2(0, -half_line_length), Vector2(0, half_line_length), color, 3.0)
	return
