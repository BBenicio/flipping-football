extends Panel

export var position = 1 setget set_position
export var teamName = "You" setget set_teamName
export var points = 0 setget set_points
export var wins = 0 setget set_wins
export var draws = 0 setget set_draws
export var losses = 0 setget set_losses
export var goalDifference = 0 setget set_goalDifference

var id = 0 setget set_id

func _ready():
	get_node("Position").set_text(str(position))
	get_node("TeamName").set_text(teamName)
	get_node("Points").set_text(str(points))
	get_node("Wins").set_text(str(wins))
	get_node("Draws").set_text(str(draws))
	get_node("Losses").set_text(str(losses))
	get_node("GoalDifference").set_text("%+d" % goalDifference)

func setNodeText(path, text):
	if has_node(path):
		get_node(path).set_text(text)

func set_id(i):
	id = i
	if id == 0:
		get_node("PlayerBg").show()
	else:
		get_node("PlayerBg").hide()

func useArray(row):
	set_position(int(row[0]))
	set_teamName(row[1])
	set_points(int(row[2]))
	set_wins(int(row[3]))
	set_draws(int(row[4]))
	set_losses(int(row[5]))
	set_goalDifference(int(row[6]))
	if row.size() >= 8:
		set_id(row[7])

func set_position(p):
	position = p
	setNodeText("Position", str(p))

func set_teamName(n):
	teamName = n
	setNodeText("TeamName", n)

func set_points(p):
	points = p
	setNodeText("Points", str(p))

func set_wins(w):
	wins = w
	setNodeText("Wins", str(w))

func set_draws(d):
	draws = d
	setNodeText("Draws", str(d))

func set_losses(l):
	losses = l
	setNodeText("Losses", str(l))

func set_goalDifference(gd):
	goalDifference = gd
	setNodeText("GoalDifference", "%+d" % gd)