extends Node

var tween = null
var tint = null
var button = null
var menu = null

var signalConnected = false

var p = 0

func _ready():
	tween = get_node("Tween")
	tint = get_node("Tint")
	button = get_node("PauseButton")
	menu = get_node("Menu")

	opacity(0)

	set_process_input(true)

func _input(event):
	if event.is_action_released("ui_cancel"):
		button.set_pressed(p == 0)
		startTween()

func startTween():
	tween.remove_all()
	if signalConnected:
		tween.disconnect("tween_complete", self, "togglePause")
		signalConnected = false

	tween.interpolate_method(self, "opacity", p, 0 if p != 0 else 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(menu, "rect/pos", menu.get_pos(), Vector2(0, 1920 if p != 0 else 0), 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)

	if not get_tree().is_paused():
		get_tree().set_pause(true)
	else:
		tween.connect("tween_complete", self, "togglePause")
		signalConnected = true

	tween.start()

func togglePause(a, b):
	get_tree().set_pause(false)

func pauseButtonToggled(pressed):
	startTween()

func menuButtonPressed():
	get_tree().change_scene("res://Screens/Menu.tscn")
	get_tree().set_pause(false)

func opacity(x):
	tint.set_modulate(Color(1, 1, 1, x))
	p = x

func resumeButtonPressed():
	button.set_pressed(false)
	startTween()
