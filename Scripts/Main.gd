extends Node

const MATCH_TIME = 90

var ball = null
var leftPlayer = null
var rightPlayer = null

var indicator = null

var timer = null

var goalLabel = null
var goalTween = null

var light = null
var lightTween = null

var clock = null
var score = null

var globals = null

var reset = false
var resetPhase = 0
var gameOver = false

var timeLeft = MATCH_TIME
var leftGoals = 0
var rightGoals = 0

var ballStillTime = 0
var ballLastPosition = null

func _ready():
	randomize()

	globals = get_node("/root/GlobalHack")

	ball = get_node("Ball")
	leftPlayer = get_node("Left Player")
	rightPlayer = get_node("Right Player")
	timer = get_node("Goal Timer")
	clock = get_node("HUD/Clock")
	score = get_node("HUD/Score")
	goalLabel = get_node("HUD/Goal")
	goalTween = get_node("HUD/Goal Tween")

	light = get_node("Light")
	lightTween = get_node("Light/Tween")

	indicator = get_node("Indicator")
	var t = indicator.get_node("Tween")
	t.interpolate_method(self, "indicatorFade", 1, 0, 1, Tween.TRANS_QUAD, Tween.EASE_IN, 5)
	t.start()

	var time = 0.25
	for i in range(6):
		lightTween.interpolate_property(light, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_QUAD, Tween.EASE_OUT, 2 * i * time)
		lightTween.interpolate_property(light, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), time, Tween.TRANS_QUAD, Tween.EASE_IN, (2 * i + 1) * time)

	leftPlayer.setKit(globals.player["shirt"], globals.player["shorts"], globals.player["shoes"])
	leftPlayer.setSkin(globals.player["skin"])
	leftPlayer.setHair(globals.player["hair"], globals.player["hairColor"])

	leftPlayer.distance = globals.player["distance"]
	leftPlayer.height = globals.player["height"]
	leftPlayer.speed = globals.player["speed"]

	setupAi()

	ballLastPosition = ball.get_pos()

	setup()

	set_process_input(true)
	set_fixed_process(true)

func setupAi():
	var skinColors = ["ffccaa", "ffb380", "ff9955", "502d16", "a05a2c", "d38d5f"]
	var hairColors = ["a91e10", "ded638", "56280f", "161616"]

	if Globals.get("quickMatch"):
		rightPlayer.player.distance = globals.player["distance"]
		rightPlayer.player.height = globals.player["height"]
		rightPlayer.player.speed = globals.player["speed"]
		rightPlayer.level = rightPlayer.Level.BASIC if randf() < 0.5 else rightPlayer.Level.SIMPLE
		rightPlayer.player.setKit(Color(randf(), randf(), randf()), Color(randf(), randf(), randf()), Color(randf(), randf(), randf()))

		rightPlayer.player.setSkin(Color(skinColors[randi() % skinColors.size()]))

		var c = Color(hairColors[randi() % hairColors.size()])
		c.v = 0.5 + randf() * c.v
		rightPlayer.player.setHair(randi() % 8, c)
	else:
		var file = File.new()
		file.open("res://Data/teams.csv", File.READ)

		var selection = randi() % 19
		if Globals.has("match/team") and Globals.get("match/team") >= 0:
			selection = Globals.get("match/team")

		for i in range(selection):
			file.get_line()

		var values = file.get_csv_line()
		rightPlayer.player.setSkin(Color(skinColors[int(values[0])]))
		rightPlayer.player.setHair(int(values[1]), Color(skinColors[int(values[2])]))
		rightPlayer.player.setKit(Color(values[3]), Color(values[4]), Color(values[5]))

		rightPlayer.player.distance = int(values[6])
		rightPlayer.player.height = int(values[7])
		rightPlayer.player.speed = int(values[8])

		rightPlayer.level = rightPlayer.Level.BASIC if int(values[8]) == 0 else rightPlayer.Level.SIMPLE

		file.close()

func _input(event):
	if event.is_action_pressed("left"):
		leftPlayer.backFlip = true
	elif event.is_action_released("left"):
		leftPlayer.backFlip = false
	if event.is_action_pressed("right"):
		leftPlayer.frontFlip = true
	elif event.is_action_released("right"):
		leftPlayer.frontFlip = false

func indicatorFade(a):
	indicator.set_modulate(Color(1, 1, 1, a))

func _fixed_process(delta):
	indicator.set_pos(Vector2(leftPlayer.get_pos().x, leftPlayer.get_pos().y - 120))

	if ballLastPosition.distance_to(ball.get_pos()) < 30:
		ballStillTime += delta
		if ballStillTime >= 4:
			start_ball()
			print("the ball has been still for too long")
	else:
		ballStillTime = 0
		ballLastPosition = ball.get_pos()


	if resetPhase == 1:
		setup()
		resetPhase = 0
	if reset or ball.get_pos().x < -100 or ball.get_pos().x > 2020 or ball.get_pos().y < -100 or ball.get_pos().y > 1080:
		# this is needed to prevend crazyness on "kickoff"
		resetPhase = 1
		ball.set_pos(Vector2(960, 300))
		ball.set_linear_velocity(Vector2(0, 0))
		ball.set_applied_force(Vector2(0, 0))
		reset = false

func setup():
	start_ball()

	leftPlayer.get_node("Flip Tween").stop_all()
	while leftPlayer.isFlipping:
		leftPlayer.doneFlipping(null, null)

	leftPlayer.set_pos(Vector2(450, 784))
	leftPlayer.set_rotd(0)

	rightPlayer.player.get_node("Flip Tween").stop_all()
	while rightPlayer.player.isFlipping:
		rightPlayer.player.doneFlipping(null, null)

	rightPlayer.player.set_pos(Vector2(1920 - 450, 784))
	rightPlayer.player.set_rotd(0)

func start_ball():
	ball.set_pos(Vector2(960, 300))
	ball.set_linear_velocity(Vector2(0, 0))
	ball.set_applied_force(Vector2(0, 0))
	ball.set_angular_velocity(-2 * PI)
	ball.apply_impulse(Vector2(0, 0), Vector2(rand_range(-50, 50), rand_range(-50, 50)))

func _on_Left_Goal_body_enter( body ):
	if body == ball and timer.get_time_left() <= 0 and not gameOver:
		rightGoals += 1
		goal()

func _on_Right_Goal_body_enter( body ):
	if body == ball and timer.get_time_left() <= 0 and not gameOver:
		leftGoals += 1
		goal()

func goal():
	timer.start()
	score.set_text(str(leftGoals) + " - " + str(rightGoals))

	goalTween.interpolate_property(goalLabel, "rect/pos", Vector2(-372, goalLabel.get_pos().y), Vector2(774, goalLabel.get_pos().y), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	goalTween.interpolate_property(goalLabel, "rect/pos", Vector2(774, goalLabel.get_pos().y), Vector2(1920, goalLabel.get_pos().y), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1)
	goalTween.start()

func clockTick():
	timeLeft -= 1

	if timeLeft == 10:
		lightTween.start()

	if timeLeft >= 0:
		clock.set_text(str(timeLeft))
	if timeLeft == 0:
		if not Globals.get("quickMatch"):
			timer.start()
		gameOver = true
		light.set_modulate(Color(1, 1, 1, 1))
	elif timeLeft == -timer.get_wait_time():
		Globals.set("match/result", leftGoals - rightGoals)
		Globals.set("match/prizeGiven", false)
		if Globals.get("quickMatch"):
			get_tree().change_scene("res://Screens/Menu.tscn")
		elif Globals.get("leagueMatch"):
			get_tree().change_scene("res://Screens/League.tscn")

		gameOver = false
		timeLeft = MATCH_TIME
		leftGoals = 0
		rightGoals = 0
		score.set_text("0 - 0")
		clock.set_text(str(timeLeft))
		light.set_modulate(Color(1, 1, 1, 0))

func setResetTrue(): #ugh this is just ridiculous
	reset = true