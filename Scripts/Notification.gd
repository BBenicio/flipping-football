extends Panel

export(Texture) var icon setget set_icon
export var text = "" setget set_text
export(Vector2) var from
export(Vector2) var to
export var time = 1.0
export var delay = 0.0

var iconFrame = null
var textLabel = null
var tween = null

func _ready():
	iconFrame = get_node("Icon")
	iconFrame.set_texture(icon)

	textLabel = get_node("Text")
	textLabel.set_text(text)

	tween = get_node("Tween")
	tween.interpolate_property(self, "rect/pos", from, to, time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, delay)
	tween.interpolate_property(self, "rect/pos", to, from, time / 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, delay + time * 1.5)

	set_pos(from)

func set_icon(i):
	icon = i
	if iconFrame != null:
		iconFrame.set_texture(i)

func set_text(t):
	text = t
	if textLabel != null:
		textLabel.set_text(t)

func pop():
	tween.start()