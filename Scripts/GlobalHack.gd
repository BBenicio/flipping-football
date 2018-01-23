extends Node


func _ready():
	if not Globals.has("debugging"):
		Globals.set("debugging", true)
		Globals.set_persisting("debugging", true)

	if not Globals.has("player/skin") or Globals.get("debugging"):
		Globals.set("player/skin", Color("ffb380"))
		Globals.set_persisting("player/skin", true)

		Globals.set("player/hair", 1)
		Globals.set_persisting("player/hair", true)

		Globals.set("player/hairColor", Color(0.1, 0.1, 0.1))
		Globals.set_persisting("player/hairColor", true)

		Globals.set("player/shirt", Color(0, 0, 0.67))
		Globals.set_persisting("player/shirt", true)

		Globals.set("player/shorts", Color(0.8, 0.8, 0.8))
		Globals.set_persisting("player/shorts", true)

		Globals.set("player/shoes", Color(0.2, 0.2, 0.2))
		Globals.set_persisting("player/shoes", true)

		Globals.set("player/distance", 0)
		Globals.set_persisting("player/distance", true)

		Globals.set("player/height", 0)
		Globals.set_persisting("player/height", true)

		Globals.set("player/speed", 0)
		Globals.set_persisting("player/speed", true)

	if not Globals.has("player/name") or Globals.get("debugging"):
		Globals.set("player/name", "My Team")
		Globals.set_persisting("player/name", true)

	if not Globals.has("money") or Globals.get("debugging"):
		Globals.set("money", 100)
		Globals.set_persisting("money", true)

	if not Globals.has("league/table") or Globals.get("debugging"):
		resetLeague()

		Globals.set_persisting("league/table", true)

	if not Globals.has("league/matches") or Globals.get("debugging"):
		resetMatches()

		Globals.set_persisting("league/matches", true)
		Globals.set_persisting("league/round", true)

	if not Globals.has("league/reset") or Globals.get("debugging"):
		Globals.set("league/reset", false)
		Globals.set_persisting("league/reset", true)

	Globals.save()

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

	Globals.set("league/table", table)

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

	Globals.set("league/matches", matches)
	Globals.set("league/round", 0)