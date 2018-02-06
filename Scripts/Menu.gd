extends Node

const TRANSITION_TIME = 0.5

var mainMenu = null
var kitMenu = null
var playerMenu = null
var settingsMenu = null

var tween = null
var moneyLabel = null

var notification = null

var globals = null

func _ready():
	get_node("/root/Music").play()

	mainMenu = get_node("MainMenu")
	kitMenu = get_node("KitMenu")
	playerMenu = get_node("PlayerMenu")
	settingsMenu = get_node("SettingsMenu")

	tween = get_node("Tween")
	moneyLabel = get_node("Money")

	notification = get_node("Notification")

	globals = get_node("/root/GlobalHack")

	moneyLabel.set_text("$ " + str(globals.money))

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

		globals.money += prize
		moneyLabel.set_text("$ " + str(globals.money))

		Globals.set("match/prizeGiven", true)


func quickMatchCallback(a, b):
	Globals.set("quickMatch", true)
	get_tree().change_scene("res://Screens/Main.tscn")

func quickMatch():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "quickMatchCallback")
	tween.start()

func editKit():
	kitMenu.setup()

	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(kitMenu, "rect/pos", kitMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.start()

func editPlayer():
	playerMenu.setup()

	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(playerMenu, "rect/pos", playerMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.start()

func kitMenuDone():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.interpolate_property(kitMenu, "rect/pos", kitMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	moneyLabel.set_text("$ " + str(globals.money))

	globals.saveGame()

func playerMenuDone():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.interpolate_property(playerMenu, "rect/pos", playerMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	moneyLabel.set_text("$ " + str(globals.money))

	globals.saveGame()

func league():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "leagueCallback")
	tween.start()

func leagueCallback(a, b):
	get_tree().change_scene("res://Screens/League.tscn")

func multiplayer():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.connect("tween_complete", self, "multiplayerCallback")
	tween.start()

func multiplayerCallback(a, b):
	get_tree().change_scene("res://Screens/Multiplayer.tscn")

func settingsMenuDone():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.interpolate_property(settingsMenu, "rect/pos", settingsMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func settings():
	tween.interpolate_property(mainMenu, "rect/pos", mainMenu.get_pos(), Vector2(1920, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(settingsMenu, "rect/pos", settingsMenu.get_pos(), Vector2(0, 0), TRANSITION_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT, TRANSITION_TIME)
	tween.start()

	settingsMenu.setup()
