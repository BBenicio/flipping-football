extends Node

const CLIENT_HOST_PORT = 7128
const HOST_CLIENT_PORT = 7129

enum {
	PLAYER_INFO,
	SETUP,
	START_BALL,
	LEFT_FLIP,
	RIGHT_FLIP,
	BALL_UPDATE,
	CLOCK_TICK,
	IM_HERE,
	GAME_OVER,
	HOST_GOAL,
	CLIENT_GOAL,
	RESET_BALL,
	REQUEST_PLAYER_INFO
}

const MATCH_TIME = 90

export var ballUpdateInterval = 0.1
export var timeout = 4

export var indicatorDistance = 140

var ballUpdate = 0
var timeoutCounter = 0
var ballUpdateDict = {
	pos = null,
	vel = null
}

var sender = PacketPeerUDP.new()
var reciever = PacketPeerUDP.new()
var host = false
var ip = null
var ballImpulse = null
var started = false

var ball = null

var timer = null

var goalLabel = null
var goalTween = null

var light = null
var lightTween = null

var clock = null
var score = null

var globals = null

var thisPlayer = null
var otherPlayer = null
var otherDone = false

var indicator = null

var reset = false
var resetPhase = 0
var gameOver = false

var timeLeft = MATCH_TIME
var hostGoals = 0
var clientGoals = 0

var ballStillTime = 0
var ballLastPosition = null


func send(code, data):
	sender.put_var({
		code = code,
		data = data
	})

func _ready():
	globals = get_node("/root/GlobalHack")

	get_node("/root/Music").stop()
	get_node("Crowd").set_default_volume(globals.settings["soundVolume"])

	ball = get_node("Ball")
	timer = get_node("Goal Timer")
	clock = get_node("HUD/Clock")
	score = get_node("HUD/Score")
	goalLabel = get_node("HUD/Goal")
	goalTween = get_node("HUD/Goal Tween")

	light = get_node("Light")
	lightTween = get_node("Light/Tween")

	host = Globals.get("multiplayer/host")
	ip = Globals.get("multiplayer/ip")

	if host:
		sender.set_send_address(ip, HOST_CLIENT_PORT)
		reciever.listen(CLIENT_HOST_PORT)
	else:
		sender.set_send_address(ip, CLIENT_HOST_PORT)
		reciever.listen(HOST_CLIENT_PORT)

	send(REQUEST_PLAYER_INFO, null)

	if host:
		thisPlayer = get_node("Host")
		otherPlayer = get_node("Client")
		otherPlayer.makeRightPlayer()

		get_node("Host Goal").connect("body_enter", self, "hostGoalBodyEnter")
		get_node("Client Goal").connect("body_enter", self, "clientGoalBodyEnter")
	else:
		otherPlayer = get_node("Host")
		thisPlayer = get_node("Client")
		thisPlayer.makeRightPlayer()

	indicator = get_node("Indicator")
	indicator.set_pos(Vector2(thisPlayer.get_pos().x, thisPlayer.get_pos().y - indicatorDistance))
	var t = indicator.get_node("Tween")
	t.interpolate_method(self, "indicatorFade", 1, 0, 1, Tween.TRANS_QUAD, Tween.EASE_IN, 5)
	t.start()

	thisPlayer.setKit(globals.player["shirt"], globals.player["shorts"], globals.player["shoes"])
	thisPlayer.setSkin(globals.player["skin"])
	thisPlayer.setHair(globals.player["hair"], globals.player["hairColor"])

	thisPlayer.distance = globals.player["distance"]
	thisPlayer.height = globals.player["height"]
	thisPlayer.speed = globals.player["speed"]

	thisPlayer.connect("started_flipping", self, "flip")
	otherPlayer.connect("started_flipping", self, "otherFlip")

	var time = 0.25
	for i in range(6):
		lightTween.interpolate_property(light, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), time, Tween.TRANS_QUAD, Tween.EASE_OUT, 2 * i * time)
		lightTween.interpolate_property(light, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), time, Tween.TRANS_QUAD, Tween.EASE_IN, (2 * i + 1) * time)

	#print("Waiting for player info")
	#reciever.wait()
	#var got = reciever.get_var()
	#if typeof(got) == TYPE_DICTIONARY and got["code"] == PLAYER_INFO:
	#	doOther(got["data"])
	#else:
	#	print("Got code ", got["code"], " when expecting code 0")

	#if host:
	#	setup()

	get_tree().set_pause(true)

	set_process(true)
	set_process_input(true)

func setup():
	if not started:
		started = true

		get_tree().set_pause(false)

		get_node("Clock Timer").connect("timeout", self, "clockTick")
		get_node("Clock Timer").start()

	if host:
		send(SETUP, null)
		start_ball(Vector2(rand_range(-50, 50), rand_range(-50, 50)))

	var hostPlayer = get_node("Host")
	var clientPlayer = get_node("Client")

	hostPlayer.get_node("Flip Tween").stop_all()
	while hostPlayer.isFlipping:
		hostPlayer.doneFlipping(null, null)

	hostPlayer.set_pos(Vector2(450, 784))
	hostPlayer.set_rotd(0)

	clientPlayer.get_node("Flip Tween").stop_all()
	while clientPlayer.isFlipping:
		clientPlayer.doneFlipping(null, null)

	clientPlayer.set_pos(Vector2(1920 - 450, 784))
	clientPlayer.set_rotd(0)

func start_ball(ballImpulse):
	if host:
		send(START_BALL, ballImpulse)
		ballLastPosition = Vector2(960, 300)

	ball.set_pos(Vector2(960, 300))
	ball.set_linear_velocity(Vector2(0, 0))
	ball.set_applied_force(Vector2(0, 0))
	ball.set_angular_velocity(-2 * PI)
	ball.apply_impulse(Vector2(0, 0), ballImpulse)

func indicatorFade(a):
	indicator.set_modulate(Color(1, 1, 1, a))

func _input(event):
	if event.is_action_pressed("left"):
		thisPlayer.backFlip = true
	elif event.is_action_released("left"):
		thisPlayer.backFlip = false
	if event.is_action_pressed("right"):
		thisPlayer.frontFlip = true
	elif event.is_action_released("right"):
		thisPlayer.frontFlip = false

func clockTick():
	if host:
		send(CLOCK_TICK, timeLeft)
	else:
		send(IM_HERE, null)

	timeLeft -= 1

	if timeLeft == 10:
		lightTween.start()

	if timeLeft >= 0:
		clock.set_text(str(timeLeft))

	if timeLeft == 0:
		light.set_modulate(Color(1, 1, 1, 1))
		if host:
			get_node("Crowd").play("crowd_yes" if hostGoals > clientGoals else "crowd_no")
			gameOver = true
			send(GAME_OVER, null)
		else:
			get_node("Crowd").play("crowd_yes" if hostGoals < clientGoals else "crowd_no")
	elif timeLeft == -timer.get_wait_time():
		var result = hostGoals - clientGoals
		Globals.set("match/result", result if host else -result)
		Globals.set("match/prizeGiven", false)
		Globals.set("multiplayer/timeout", false)

		get_tree().change_scene("res://Screens/Multiplayer.tscn")

func doOther(p):
	otherPlayer.setKit(p["shirt"], p["shorts"], p["shoes"])
	otherPlayer.setSkin(p["skin"])
	otherPlayer.setHair(p["hair"], p["hairColor"])

	otherPlayer.distance = p["distance"]
	otherPlayer.height = p["height"]
	otherPlayer.speed = p["speed"]

	otherDone = true

func _process(delta):
	indicator.set_pos(Vector2(thisPlayer.get_pos().x, thisPlayer.get_pos().y - 120))

	if host and not get_tree().is_paused():
		if ballLastPosition.distance_to(ball.get_pos()) < 30:
			ballStillTime += delta
			if ballStillTime >= 4:
				ballStillTime = 0
				start_ball(Vector2(rand_range(-50, 50), rand_range(-50, 50)))
				print("the ball has been still for too long")
		else:
			ballStillTime = 0
			ballLastPosition = ball.get_pos()

		if resetPhase == 1:
			setup()
			resetPhase = 0
		if reset or ball.get_pos().x < -100 or ball.get_pos().x > 2020 or ball.get_pos().y < -100 or ball.get_pos().y > 1080:
			# this is needed to prevend crazyness on "kickoff"
			send(RESET_BALL, null)
			resetPhase = 1
			ball.set_pos(Vector2(960, 300))
			ball.set_linear_velocity(Vector2(0, 0))
			ball.set_applied_force(Vector2(0, 0))
			reset = false

		ballUpdate += delta
		if ballUpdate > ballUpdateInterval:
			ballUpdate = 0

			ballUpdateDict["pos"] = ball.get_pos()
			ballUpdateDict["vel"] = ball.get_linear_velocity()

			send(BALL_UPDATE, ballUpdateDict)

	timeoutCounter += delta
	processRecievedData(reciever.get_var())

	if timeoutCounter > timeout:
		print("TIMEOUT")
		sender.close()
		reciever.close()

		var result = hostGoals - clientGoals
		Globals.set("match/result", result if host else -result)
		Globals.set("match/prizeGiven", false)
		Globals.set("multiplayer/timeout", true)

		get_tree().change_scene("res://Screens/Multiplayer.tscn")

	if not otherDone:
		send(REQUEST_PLAYER_INFO, null)
	elif not started and host:
		setup()

func processRecievedData(got):
	if got != null:
		timeoutCounter = 0

	while got != null:
		if typeof(got) != TYPE_DICTIONARY:
			got = reciever.get_var()
			continue

		if got["code"] == PLAYER_INFO:
			doOther(got["data"])
		if got["code"] == SETUP:
			setup()
		elif got["code"] == START_BALL:
			start_ball(got["data"])
		elif got["code"] == LEFT_FLIP:
			otherPlayer.backFlip = true
			otherPlayer.set_pos(got["data"])
		elif got["code"] == RIGHT_FLIP:
			otherPlayer.frontFlip = true
			otherPlayer.set_pos(got["data"])
		elif got["code"] == BALL_UPDATE:
			ball.set_pos(got["data"]["pos"])
			ball.set_linear_velocity(got["data"]["vel"])
		elif got["code"] == CLOCK_TICK:
			timeLeft = got["data"]
		elif got["code"] == IM_HERE:
			pass # just to reset the timeout counter
		elif got["code"] == GAME_OVER:
			gameOver = true
		elif got["code"] == CLIENT_GOAL:
			clientGoals = got["data"]
			goal()
		elif got["code"] == HOST_GOAL:
			hostGoals = got["data"]
			goal()
		elif got["code"] == RESET_BALL:
			ball.set_pos(Vector2(960, 300))
			ball.set_linear_velocity(Vector2(0, 0))
			ball.set_applied_force(Vector2(0, 0))
		elif got["code"] == REQUEST_PLAYER_INFO:
			send(PLAYER_INFO, globals.player)
		else:
			print(got["code"], ": unknown code")

		got = reciever.get_var()

func flip(dir):
	send(LEFT_FLIP if dir < 0 else RIGHT_FLIP, thisPlayer.get_pos())

func otherFlip(dir):
	otherPlayer.backFlip = false
	otherPlayer.frontFlip = false

func hostGoalBodyEnter( body ):
	if body == ball and timer.get_time_left() <= 0 and not gameOver:
		get_node("Crowd").play("crowd_no" if host else "crowd_yes")

		clientGoals += 1
		send(CLIENT_GOAL, clientGoals)
		goal()

func clientGoalBodyEnter( body ):
	if body == ball and timer.get_time_left() <= 0 and not gameOver:
		get_node("Crowd").play("crowd_yes" if host else "crowd_no")

		hostGoals += 1
		send(HOST_GOAL, hostGoals)
		goal()

func goal():
	timer.start()
	score.set_text(str(hostGoals) + " - " + str(clientGoals))

	goalTween.interpolate_property(goalLabel, "rect/pos", Vector2(-372, goalLabel.get_pos().y), Vector2(774, goalLabel.get_pos().y), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	goalTween.interpolate_property(goalLabel, "rect/pos", Vector2(774, goalLabel.get_pos().y), Vector2(1920, goalLabel.get_pos().y), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 1)
	goalTween.start()

func setResetTrue():
	reset = true