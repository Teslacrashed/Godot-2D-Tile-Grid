extends MarginContainer

signal Players_unit_active(idx)  # idx: int

const _BLUE: Color = Color(0, 1, 1, 1)  # Movement.
const _ORANGE: Color = Color(1, 0.65, 0, 1)  # Offense.
const _YELLOW: Color = Color(1, 1, 0, 1)  # Defense.
const _GREEN: Color = Color(0, 1, 0, 1)  # Health.

const _COLORS: Array = [_BLUE, _ORANGE, _YELLOW, _GREEN]

var active: bool = false
var index: int
var panel_color: Color

# The labels and progress bars
@onready var panel := $VBoxContainer/Panel
@onready var alias := $VBoxContainer/Panel/VBoxContainer/Alias
@onready var mv := $VBoxContainer/Panel/VBoxContainer/MV
@onready var at := $VBoxContainer/Panel/VBoxContainer/AT
@onready var df := $VBoxContainer/Panel/VBoxContainer/DF
@onready var hp_current := $VBoxContainer/Panel/VBoxContainer/HBoxContainer/HPCurrent
@onready var hp_maximum := $VBoxContainer/Panel/VBoxContainer/HBoxContainer/HPMaximum
@onready var lifebar := $VBoxContainer/Panel/VBoxContainer/TextureProgressBar


func _ready() -> void:
	Players.init_panel.connect(_on_Players_init_panel)
	print("Ready: ", self.name)
	return


func set_panel(_idx: int, unit: Unit, _color: Color) -> void:
	unit.hp_hurt.connect(_on_Unit_hp_hurt)
	unit.hp_heal.connect(_on_Unit_hp_heal)
	unit.stat_bonus.connect(_on_Unit_stat_changed)
	# Players.unit_active.connect(_on_Players_unit_active)

	set_alias(unit.alias)
	set_mv(unit.get_mv())
	set_at(unit.get_at())
	set_df(unit.get_df())
	set_hp_current(unit.hp_current)
	set_hp_maximum(unit.get_hp())
	index = _idx
	panel_color = _color
	return


func switch_active(idx: int) -> void:
	if index == idx:
		active = true
		self.modulate = panel_color
	else:
		active = false
		self.modulate = Color(1, 1, 1, 1)
	return


func set_alias(value: String) -> void:
	# Set the character's name.
	alias.text = value
	return


func set_mv(value: int) -> void:
	# Set the character's move stat value.
	mv.text = "Mv. " + str(value)
	return


func set_at(value: int) -> void:
	# Set the character's attack stat value.
	at.text = "At. " + str(value)
	return


func set_df(value: int) -> void:
	# Set character's defense stat value.
	df.text = "Df. " + str(value)
	return


func set_hp_current(value: int) -> void:
	# Set character's current and max health stat values.
	hp_current.text = "Hp " + str(value)
	return


func set_hp_maximum(value: int) -> void:
	# Set character's current and max health stat values.
	hp_maximum.text = "/ " + str(value)
	lifebar.max_value = value
	lifebar.value = value
	return


func _on_Players_unit_active(_idx: int) -> void:
	switch_active(_idx)
	return


func _on_Unit_hp_hurt(_hp_current: int) -> void:
	# tween.stop(lifebar, "value")
	# tween.interpolate_property(lifebar, "value", lifebar.value, _hp_current, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	# tween.start()
	set_hp_current(_hp_current)
	return


func _on_Unit_hp_heal(_hp_current: int) -> void:
	# tween.stop(lifebar, "value")
	# tween.interpolate_property(lifebar, "value", lifebar.value, _hp_current, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	# tween.start()
	set_hp_current(_hp_current)
	return


func _on_Unit_stat_changed(stat, value: int) -> void:
	set_at(value)
	return


func _on_Players_init_panel(_idx: int, _unit: Unit) -> void:
	var color = _COLORS[_idx]
	set_panel(_idx, _unit, color)
	return
