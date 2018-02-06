extends Control

signal cancel
signal done

var globals = null
var music = null

func _ready():
	globals = get_node("/root/GlobalHack")
	music = get_node("/root/Music")

	if OS.get_name() == "Android":
		get_node("Panel/Fullscreen").hide()

	setup()

func setup():
	get_node("Panel/SfxSlider").set_value(globals.settings["soundVolume"])
	get_node("Panel/MusicSlider").set_value(globals.settings["musicVolume"])
	get_node("Panel/Fullscreen").set_pressed(globals.settings["fullscreen"])

func sfxSliderValueChanged(value):
	globals.settings["soundVolume"] = value

func musicSliderValueChanged(value):
	globals.settings["musicVolume"] = value

func fullscreenToggled(pressed):
	globals.settings["fullscreen"] = pressed

	OS.set_window_fullscreen(pressed)

func cancelButtonPressed():
	globals.loadSettings()

	OS.set_window_fullscreen(globals.settings["fullscreen"])

	emit_signal("cancel")

func doneButtonPressed():
	globals.saveSettings()

	emit_signal("done")
