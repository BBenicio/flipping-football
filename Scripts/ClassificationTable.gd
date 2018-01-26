extends ScrollContainer

export var rows = 20

var rowScene = preload("res://Objects/ClassificationRow.tscn")
var rowList = []

var list = null

var globals = null

func _ready():
	list = get_node("List")

	globals = get_node("/root/GlobalHack")

	var title = rowScene.instance()
	list.add_child(title)
	title.setNodeText("Position", "")
	title.setNodeText("TeamName", "")
	title.setNodeText("Points", "P")
	title.setNodeText("Wins", "W")
	title.setNodeText("Draws", "D")
	title.setNodeText("Losses", "L")
	title.setNodeText("GoalDifference", "GD")

	for i in range(rows):
		var r = rowScene.instance()

		r.position = i + 1
		rowList.append(r)

		list.add_child(r)

	useArray(globals.league["table"])


	sort()

func sort():
	rowList.sort_custom(self, "compare")

	var table = globals.league["table"]

	for i in range(rowList.size()):
		rowList[i].position = i + 1
		list.move_child(rowList[i], i + 1)
		table[i][0] = i + 1
		table[i][1] = rowList[i].teamName
		table[i][2] = rowList[i].points
		table[i][3] = rowList[i].wins
		table[i][4] = rowList[i].draws
		table[i][5] = rowList[i].losses
		table[i][6] = rowList[i].goalDifference
		table[i][7] = rowList[i].id

	globals.league["table"] = table
	rowList.sort_custom(self, "idSort")

	globals.saveGame()

func idSort(a, b):
	return a.id < b.id

func compare(a, b):
	if a.points != b.points:
		return a.points > b.points
	elif a.goalDifference != b.goalDifference:
		return a.goalDifference > b.goalDifference
	elif a.wins != b.wins:
		return a.wins > b.points
	elif a.draws != b.draws:
		return a.draws > b.draws
	elif a.losses != b.losses:
		return a.losses < b.losses
	else:
		return a.position < b.position

func getRow(i):
	return rowList[i]

func useArray(table):
	for i in range(table.size()):
		rowList[i].useArray(table[i])