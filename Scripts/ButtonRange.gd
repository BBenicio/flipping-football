extends Control

signal value_changed(value)

var progressBar = null
var plusButton = null

func _ready():
	progressBar = get_node("ProgressBar")
	plusButton = get_node("Plus")

func set_value(v):
	progressBar.set_value(v)

	if v == progressBar.get_max():
		plusButton.set_disabled(true)

	emit_signal("value_changed", get_value())

func get_value():
	return progressBar.get_value()

func set_max(m):
	progressBar.set_max(m)

func plus():
	set_value(get_value() + progressBar.get_step())

func set_disabled(dis):
	plusButton.set_disabled(dis)