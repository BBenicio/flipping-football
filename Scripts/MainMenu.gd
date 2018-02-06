extends Control

signal league
signal quickMatch
signal multiplayer
signal editPlayer
signal settings
signal editKit

var globals = null

func _ready():
	globals = get_node("/root/GlobalHack")

	if OS.get_name() == "HTML5":
		get_node("QuitButton").hide()
		get_node("MultiplayerButton").hide()

func leagueButtonPressed():
	emit_signal("league")

func quickMatchButtonPressed():
	emit_signal("quickMatch")

func multiplayerButtonPressed():
	emit_signal("multiplayer")

func editPlayerButtonPressed():
	emit_signal("editPlayer")

func settingsButtonPressed():
	emit_signal("settings")

func editKitButtonPressed():
	emit_signal("editKit")

func quitButtonPressed():
	globals.saveGame()
	globals.saveSettings()

	get_tree().quit()
