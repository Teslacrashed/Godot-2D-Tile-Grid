class_name Unit
extends Node2D

var alias: String = "unit"
var idx: int
var movement_points: int = 4


var selected: bool = false:
	set(bit):
		selected = bit
		if selected == true:
			_sprite.material.set_shader_parameter('visible', true)
		else:
			_sprite.material.set_shader_parameter('visible', false)
		return


var coordinates: Vector2i

@onready var _area: Area2D = $Area2D
@onready var _collision: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var _sprite: Sprite2D = $Area2D/Sprite2D


func _ready() -> void:
	print("Ready: ", alias)
	return
