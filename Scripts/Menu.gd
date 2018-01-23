extends Node

const TRANSITION_TIME = 0.5

var mainMenu = null
var kitMenu = null
var playerMenu = null
var tween = null
var moneyLabel = null

var notification = null

func _ready():
	mainMenu = get_node("MainMenu")
	kitMenu = get_node("KitMenu")
	playerMenu = get_node("PlayerMenu")
	tween = get_node("Tween")
	moneyLabel = get_node("Money")

	notification = get_node("Notification")

	moneyLabel.set_text("$ " + str(Globals.get("money")))

	tween.interpolate_property(mainMenu, "rect/pos", Vector2(1920, 0), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	if Globals.has("match/result") and (not Globals.has("match/prizeGiven") or not Globals.get("match/prizeGiven")):
		var r = Globals.get("match/result")
		var prize = 10
		var text = " for that "

		if r < 0:
			prize /= 2
			text += "loss"
		elif r > 0:
			prize += prize + 2 * r
			text += "win"
		else:
			text += "draw"

		notification.set_text("You earned $ " + str(prize) + text)
		notification.pop()

		Globals.set("money", Globals.get("money") + prize)
		moneyLabel.set_text("$ " + str(Globals.get("money")))

		Globals.set("match/prizeGiven", true)

	if Globals.get("league/reset"):
		get_node("GlobalsHack").resetLeague()
		get_node("GlobalsHack").resetMatches()

		Globals.set("league/reset", false)


func quickMatch(a, b):
	Globals.set("quickMatch", true)
	get_tree().change_scene("res://Screens/Main.tscn")

func quickMatchButtonPressed():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "quickMatch")
	tween.start()

func changeKitButtonPressed():
	kitMenu.setup()

	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(kitMenu, "rect/pos", kitMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.start()

func editPlayerButtonPressed():
	playerMenu.setup()

	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(playerMenu, "rect/pos", playerMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.start()

func kitMenuDone():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.interpolate_property(kitMenu, "rect/pos", kitMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	moneyLabel.set_text("$ " + str(Globals.get("money")))

	Globals.save()

func playerMenuDone():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.interpolate_property(playerMenu, "rect/pos", playerMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	moneyLabel.set_text("$ " + str(Globals.get("money")))

	Globals.save()

func leagueButtonPressed():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "league")
	tween.start()

func league(a, b):
	get_tree().change_scene("res://Screens/League.tscn")