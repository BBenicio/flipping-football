extends WindowDialog

signal confirmed

export var text = "Are you sure?" setget set_text
export var yesText = "Yes" setget set_yesText
export var noText = "No" setget set_noText

var label = null
var yesButton = null
var noButton = null

func _ready():
	label = get_node("Text")
	label.set_text(text)

	yesButton = get_node("YesButton")
	yesButton.set_text(yesText)

	noButton = get_node("NoButton")
	noButton.set_text(noText)

func set_text(t):
	if label != null:
		label.set_text(t)

	text = t

func set_yesText(t):
	if yesButton != null:
		yesButton.set_text(t)

	yesText = t

func set_noText(t):
	if noButton != null:
		noButton.set_text(t)
	noText = t

func noButtonPressed():
	hide()

func yesButtonPressed():
	emit_signal("confirmed")
	hide()