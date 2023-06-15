extends Node2D

@onready var battlemap = $BattleMap


func _ready() -> void:
	_init_unit()
	print('Ready: ', self.name)
	return


func _init_unit() -> void:
	## Adds the 4 characters to the game map.
	var new_unit = load("res://src/unit/unit.tscn")
	var unit = new_unit.instantiate()
	add_child(unit)
	var unit_cell: Vector2i = Vector2i(5, 5)
	var cell = Map.get_tile_at(unit_cell)
	cell.unit = unit
	return
	
