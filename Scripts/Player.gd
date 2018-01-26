extends KinematicBody2D

const MOVE = 300
const JUMP = 100
const FLIP_TIME = 1.0

const MIN_X = 120
const MAX_X = 1920 - MIN_X

signal started_flipping(dir)

var backFlip = null
var frontFlip = null
var isFlipping = false

var sprite = null
var kit = null
var hair = null

var flipTween = null
var tweenEndedCount = 0

var distance = 0
var height = 0
var speed = 0

func _ready():
	set_fixed_process(true)

	sprite = get_node("Mesh/Base")
	kit = get_node("Mesh/Kit")
	hair = get_node("Mesh/Hair")

	setKit(Color(0, 0, 0.67), Color(0.8, 0.8, 0.8), Color(0.2, 0.2, 0.2))
	setHair(1, Color(0.12, 0.12, 0.12))

	flipTween = get_node("Flip Tween")
	flipTween.connect("tween_complete", self, "doneFlipping")

func getMoveDistance():
	return MOVE + 30 * distance

func getJumpHeight():
	return JUMP + 15 * height

func getFlipSpeed():
	return FLIP_TIME - 0.05 * speed

func setKit(shirt, short, shoes):
	if shirt != null:
		kit.get_child(0).set_modulate(shirt)
	if short != null:
		kit.get_child(1).set_modulate(short)
	if shoes != null:
		kit.get_child(2).set_modulate(shoes)

func setHair(style, color):
	if color != null:
		hair.set_modulate(color)
	if style != null:
		hair.set_frame(style)

func setSkin(color):
	get_node("Mesh/Base").set_modulate(color)
	get_node("Mesh/Arms").set_modulate(color)

func makeRightPlayer():
	get_node("Mesh").set_scale(Vector2(-1, 1))
	kit.get_child(0).set_modulate(Color(0.67, 0, 0))

	var shape = get_node("CollisionPolygon2D")
	var poly = shape.get_polygon()
	for i in range(poly.size()):
		var vec = poly[i]
		vec.x = -vec.x
		poly.set(i, vec)

func _fixed_process(delta):
	if not isFlipping and backFlip and not frontFlip:
		flip(1)
	elif not isFlipping and frontFlip and not backFlip:
		flip(-1)

	var pos = get_pos()
	if pos.x < 0:
		pos.x = 0
	elif pos.x > 1920:
		pos.x = 1920

	set_pos(pos)

func flip(dir):
	var move = -dir * getMoveDistance()

	if get_pos().x + move < MIN_X:
		move = MIN_X - get_pos().x
	elif get_pos().x + move > MAX_X:
		move = MAX_X - get_pos().x

	if move == 0:
		return

	emit_signal("started_flipping", sign(move))

	isFlipping = true

	set_rotd(int(round(get_rotd())) % 360)
	flipTween.remove_all()

	flipTween.interpolate_property(self, "transform/pos", get_pos(), Vector2(get_pos().x + move, get_pos().y), getFlipSpeed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	flipTween.interpolate_property(self, "transform/rot", get_rotd(), dir * 360, getFlipSpeed(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	flipTween.interpolate_method(self, "jump", get_pos().y, get_pos().y - getJumpHeight(), getFlipSpeed() / 4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	flipTween.interpolate_method(self, "jump", get_pos().y - getJumpHeight(), get_pos().y, getFlipSpeed() / 4, Tween.TRANS_QUAD, Tween.EASE_IN, getFlipSpeed() / 4)
	flipTween.interpolate_method(self, "jump", get_pos().y, get_pos().y - getJumpHeight(), getFlipSpeed() / 4, Tween.TRANS_QUAD, Tween.EASE_OUT, 2 * getFlipSpeed() / 4)
	flipTween.interpolate_method(self, "jump", get_pos().y - getJumpHeight(), get_pos().y, getFlipSpeed() / 4, Tween.TRANS_QUAD, Tween.EASE_IN, 3 * getFlipSpeed() / 4)

	flipTween.interpolate_property(get_node("Mesh/Arms"), "transform/rot", 0, 180, getFlipSpeed() / 2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	flipTween.interpolate_property(get_node("Mesh/Arms"), "transform/rot", 180, 0, getFlipSpeed() / 2, Tween.TRANS_QUAD, Tween.EASE_IN, getFlipSpeed() / 2)

	flipTween.start()

func jump(val):
	var p = get_pos()
	p.y = val
	set_pos(p)

func doneFlipping(object, key):
	tweenEndedCount += 1
	if tweenEndedCount == 8:
		isFlipping = false
		tweenEndedCount = 0