extends Node2D

enum Level {
	BASIC,
	SIMPLE
}

var level = Level.BASIC
var player = null
export(NodePath) var ballPath
var ball

func _ready():
	player = get_node("Player")
	ball = get_node(ballPath)

	player.makeRightPlayer()

	set_fixed_process(true)

func _fixed_process(delta):
	if player.isFlipping:
		return

	if level == Level.BASIC:
		basic()
	elif level == Level.SIMPLE:
		simple()

func simple():
	var v0 = ball.get_linear_velocity().y
	var h0 = ball.get_pos().y
	var h = 700 - player.getJumpHeight()
	var w = ball.get_weight()
	var d = pow(v0, 2) - 2 * w * (h0 - h)
	var t = 0
	if d >= 0:
		t = (-v0 + sqrt(d)) / w
		if t < 0 or t > player.getFlipSpeed():
			t = 0

	var ballX = ball.get_pos().x + ball.get_linear_velocity().x * t
	var ballY = ball.get_pos().y + ball.get_linear_velocity().y * t

	if ballX < player.get_pos().x - player.getMoveDistance():
		player.backFlip = true
	elif ballX < player.get_pos().x and ballY > 700 - player.getJumpHeight():
		player.backFlip = true
	else:
		player.backFlip = false

	if ballX > player.get_pos().x + player.getMoveDistance():
		player.frontFlip = true
	elif ballX > player.get_pos().x and ballY > 700 - player.getJumpHeight():
		player.frontFlip = true
	else:
		player.frontFlip = false

func basic():
	if ball.get_pos().x < player.get_pos().x - player.getMoveDistance():
		player.backFlip = true
	elif ball.get_pos().x < player.get_pos().x and ball.get_pos().y > 700 - player.getJumpHeight():
		player.backFlip = true
	else:
		player.backFlip = false

	player.frontFlip = ball.get_pos().x >= player.get_pos().x