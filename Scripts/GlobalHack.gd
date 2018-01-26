extends Node

const VERSION = 3
const SAVE_FILE = "user://savegame.sav"
const PASS = "io.benic.flippingfootball"

var player = {
	skin = Color("ffb380"),
	hair = 1,
	hairColor = Color(0.1, 0.1, 0.1),
	shirt = Color(0, 0, 0.67),
	shorts = Color(0.8, 0.8, 0.8),
	shoes = Color(0.2, 0.2, 0.2),

	distance = 0,
	height = 0,
	speed = 0,

	name = "My Team"
}

var league = {
	table = null,
	matches = null,
	week = 0
}

var money = 100

func _ready():
	if VERSION == 3:
		if Globals.has("money"):
			Globals.set_persisting("debugging", false)
			Globals.set_persisting("player/skin", false)
			Globals.set_persisting("player/hair", false)
			Globals.set_persisting("player/hairColor", false)
			Globals.set_persisting("player/shirt", false)
			Globals.set_persisting("player/shorts", false)
			Globals.set_persisting("player/shoes", false)
			Globals.set_persisting("player/distance", false)
			Globals.set_persisting("player/height", false)
			Globals.set_persisting("player/speed", false)
			Globals.set_persisting("player/name", false)
			Globals.set_persisting("money", false)
			Globals.set_persisting("league/table", false)
			Globals.set_persisting("league/matches", false)
			Globals.set_persisting("league/round", false)
			Globals.set_persisting("league/reset", false)

			Globals.save()

			player["skin"] = Globals.get("player/skin")
			player["hair"] = Globals.get("player/hair")
			player["hairColor"] = Globals.get("player/hairColor")
			player["shirt"] = Globals.get("player/shirt")
			player["shorts"] = Globals.get("player/shorts")
			player["shoes"] = Globals.get("player/shoes")
			player["distance"] = Globals.get("player/distance")
			player["height"] = Globals.get("player/height")
			player["speed"] = Globals.get("player/speed")
			player["name"] = Globals.get("player/name")

			league["table"] = Globals.get("league/table")
			league["matches"] = Globals.get("league/matches")
			league["week"] = Globals.get("league/round")

			money = Globals.get("money")

		loadGame()

		if league["table"] == null:
			resetLeague()
			resetMatches()

		saveGame()

func resetLeague():
	var file = File.new()
	file.open("res://Data/league.csv", File.READ)

	var table = []
	table.append([20, "You", 0, 0, 0, 0, 0, 0])

	for i in range(20):
		var line = file.get_csv_line()
		if line.size() >= 6:
			var team = []
			for i in range(line.size()):
				team.append(int(line[i]) if i != 1 else line[i])
			table.append(team)

	file.close()

	league["table"] = table

func resetMatches():
	var matches = []

	var file = File.new()
	file.open("res://Data/matches.csv", File.READ)
	for i in range(20):
		var l = file.get_csv_line()
		matches.append([])
		for m in l:
			matches[i].append(int(m))

	file.close()

	league["matches"] = matches
	league["week"] = 0

func saveGame():
	var file = File.new()
	file.open_encrypted_with_pass(SAVE_FILE, File.WRITE, PASS)

	var saveDict = {}
	saveDict["player"] = player
	saveDict["league"] = league
	saveDict["money"] = money

	file.store_var(saveDict.to_json())

	file.close()

func loadGame():
	var file = File.new()
	file.open_encrypted_with_pass(SAVE_FILE, File.READ, PASS)

	var saveDict = {}
	saveDict["player"] = player
	saveDict["league"] = league
	saveDict["money"] = money

	var cont = file.get_var()
	if cont == null:
		file.close()
		return

	saveDict.parse_json(cont)

	player = saveDict["player"]
	league = saveDict["league"]
	money = saveDict["money"]

	player["skin"] = colorFromCsv(player["skin"])
	player["hairColor"] = colorFromCsv(player["hairColor"])
	player["shirt"] = colorFromCsv(player["shirt"])
	player["shorts"] = colorFromCsv(player["shorts"])
	player["shoes"] = colorFromCsv(player["shoes"])

	file.close()

func colorFromCsv(csv):
	var arr = csv.split_floats(",")
	return Color(arr[0], arr[1], arr[2], arr[3])