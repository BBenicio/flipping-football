extends Node

const TRANSITION_TIME = 0.5

var moneyLabel = null
var classification = null
var nextMatchButton = null
var opponentNameLabel = null
var newLeagueButton = null
var notification = null
var tween = null

var player = null

var moneyIcon = preload("res://Images/Money.png")

var globals = null

var nextMatch = 0
var teamIndex = 1

func _ready():
	get_node("/root/Music").play()

	moneyLabel = get_node("Money")
	classification = get_node("Classification/ClassificationTable")
	nextMatchButton = get_node("ControlPanel/NextMatchButton")
	opponentNameLabel = get_node("ControlPanel/NextMatchButton/OpponentName")
	newLeagueButton = get_node("ControlPanel/NewLeagueButton")
	notification = get_node("Notification")
	tween = get_node("Tween")

	player = get_node("ControlPanel/Player")

	globals = get_node("/root/GlobalHack")

	player.setKit(globals.player["shirt"], globals.player["shorts"], globals.player["shoes"])
	player.setSkin(globals.player["skin"])
	player.setHair(globals.player["hair"], globals.player["hairColor"])

	tween.interpolate_property(get_node("Classification"), "rect/pos", Vector2(1920 + 800, 0), Vector2(800, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(get_node("ControlPanel"), "rect/pos", Vector2(1920, 0), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.start()

	nextMatch = globals.league["week"]
	teamIndex = globals.league["matches"][0][nextMatch]

	classification.rowList[0].teamName = globals.player["name"]

	if Globals.has("match/result") and (not Globals.has("match/prizeGiven") or not Globals.get("match/prizeGiven")):
		var r = Globals.get("match/result")
		var prize = 10
		var text = " for that "

		if r < 0:
			prize /= 2
			text += "loss"
			classification.rowList[0].losses += 1

			classification.rowList[teamIndex].wins += 1
			classification.rowList[teamIndex].points += 3
		elif r > 0:
			prize += prize + 2 * r
			text += "win"
			classification.rowList[0].wins += 1
			classification.rowList[0].points += 3

			classification.rowList[teamIndex].losses += 1
		else:
			text += "draw"
			classification.rowList[0].draws += 1
			classification.rowList[0].points += 1

			classification.rowList[teamIndex].draws += 1
			classification.rowList[teamIndex].points += 1

		classification.rowList[0].goalDifference += r
		classification.rowList[teamIndex].goalDifference -= r

		simulateRound()
		classification.sort()

		notification.set_icon(moneyIcon)
		notification.set_text("You earned $ " + str(prize) + text)
		notification.pop()

		globals.money += prize
		Globals.set("match/prizeGiven", true)

		if nextMatch < 18:
			nextMatch += 1
		else:
			var leaguePrize = round(2000.0 / classification.rowList[0].position)

			get_node("DoneNotification").set_text("You earned $ " + str(leaguePrize) + " from your position in the league")
			get_node("DoneNotification").pop()

			globals.money += leaguePrize

		globals.league["week"] = nextMatch
		teamIndex = globals.league["matches"][0][nextMatch]

		globals.saveGame()

	if nextMatch >= 19:
		nextMatchButton.hide()
		newLeagueButton.show()

	moneyLabel.set_text("$ " + str(globals.money))

	opponentNameLabel.set_text("vs " + classification.rowList[teamIndex].teamName)


func simulateRound():
	var done = [0, teamIndex]
	for i in range(1, 20):
		if i in done:
			continue

		var home = classification.rowList[i]
		var away = classification.rowList[globals.league["matches"][i][nextMatch]]

		done.append(home.id)
		done.append(away.id)

		var winDif = home.wins - away.wins
		var lossDif = home.losses - away.losses

		var result = winDif - lossDif + home.goalDifference - away.goalDifference
		if randi() % 2 == 0:
			result -= randi() % 4
		else:
			result += randi() % 3

		var maximum = randi() % 4
		if result < -maximum:
			result = -maximum
		elif result > maximum:
			result = maximum

		if result > 0:
			home.wins += 1
			away.losses += 1

			home.points += 3
		elif result < 0:
			home.losses += 1
			away.wins += 1

			away.points += 3
		else:
			home.draws += 1
			away.draws += 1

			home.points += 1
			away.points += 1

		home.goalDifference += result
		away.goalDifference -= result

func nextMatchButtonPressed():
	tween.interpolate_property(get_node("Classification"), "rect/pos", Vector2(800, 0), Vector2(1920 + 800, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(get_node("ControlPanel"), "rect/pos", Vector2(0, 0), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.connect("tween_complete", self, "match")
	tween.start()

func match(a, b):
	Globals.set("match/team", nextMatch)
	Globals.set("quickMatch", false)
	Globals.set("leagueMatch", true)

	get_tree().change_scene("res://Screens/Main.tscn")

func menuButtonPressed():
	tween.interpolate_property(get_node("Classification"), "rect/pos", Vector2(800, 0), Vector2(1920 + 800, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(get_node("ControlPanel"), "rect/pos", Vector2(0, 0), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.connect("tween_complete", self, "menu")
	tween.start()

func menu(a, b):
	Globals.set("match/prizeGiven", true)
	get_tree().change_scene("res://Screens/Menu.tscn")

func newLeagueButtonPressed():
	for row in classification.rowList:
		row.points = 0
		row.wins = 0
		row.losses = 0
		row.draws = 0
		row.goalDifference = 0

		nextMatch = 0

		classification.sort()

		globals.league["week"] = 0

		nextMatchButton.show()
		newLeagueButton.hide()