extends Control

signal color_changed(color)

var color = Color(1, 1, 1)
var colorFrame = null
var redSlider = null
var greenSlider = null
var blueSlider = null

func _ready():
	colorFrame = get_node("ColorFrame")
	redSlider = get_node("RedSlider")
	greenSlider = get_node("GreenSlider")
	blueSlider = get_node("BlueSlider")

func setColor(col):
	color = col
	redSlider.set_value(col.r)
	greenSlider.set_value(col.g)
	blueSlider.set_value(col.b)

func redSliderValueChanged( value ):
	color.r = value
	colorFrame.set_frame_color(color)

	emit_signal("color_changed", color)

func greenSliderValueChanged( value ):
	color.g = value
	colorFrame.set_frame_color(color)

	emit_signal("color_changed", color)

func blueSliderValueChanged( value ):
	color.b = value
	colorFrame.set_frame_color(color)

	emit_signal("color_changed", color)