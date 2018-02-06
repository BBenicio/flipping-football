extends Control

signal cancel
signal done

const CHANGE_COST = 15

var changedShirt = false
var changedShorts = false
var changedShoes = false

var cost = 0

var shirtTab = null
var shortsTab = null
var shoesTab = null

var doneButton = null

var player = null

var globals = null

func _ready():
	player = get_node("Player")

	shirtTab = get_node("KitTabContainer/Shirt")
	shortsTab = get_node("KitTabContainer/Shorts")
	shoesTab = get_node("KitTabContainer/Shoes")

	doneButton = get_node("DoneButton")

	globals = get_node("/root/GlobalHack")

	setup()

func updateCost():
	cost = 0

	if changedShirt: cost += 15
	if changedShorts: cost += 15
	if changedShoes: cost += 15

	if cost > 0:
		doneButton.set_text("Done ($ " + str(cost) + ")")
	else:
		doneButton.set_text("Done")

	if cost > globals.money:
		doneButton.set_disabled(true)

func setup():
	shirtTab.get_node("ColorPicker").setColor(globals.player["shirt"])
	shortsTab.get_node("ColorPicker").setColor(globals.player["shorts"])
	shoesTab.get_node("ColorPicker").setColor(globals.player["shoes"])

	changedShirt = false
	changedShorts = false
	changedShoes = false

	player.setKit(globals.player["shirt"], globals.player["shorts"], globals.player["shoes"])
	player.setSkin(globals.player["skin"])
	player.setHair(globals.player["hair"], globals.player["hairColor"])

	get_node("KitTabContainer/Name/LineEdit").set_text(globals.player["name"])

	doneButton.set_disabled(false)

	updateCost()

func shirtColorChanged(color):
	player.setKit(color, null, null)

	var c = globals.player["shirt"]
	changedShirt = abs(color.r - c.r) >= 0.01 or abs(color.g - c.g) >= 0.01 or abs(color.b - c.b) >= 0.01
	updateCost()

func shortsColorChanged(color):
	player.setKit(null, color, null)

	var c = globals.player["shorts"]
	changedShorts = abs(color.r - c.r) > 0.01 or abs(color.g - c.g) > 0.01 or abs(color.b - c.b) > 0.01
	updateCost()

func shoesColorChanged(color):
	player.setKit(null, null, color)

	var c = globals.player["shoes"]
	changedShoes = abs(color.r - c.r) > 0.01 or abs(color.g - c.g) > 0.01 or abs(color.b - c.b) > 0.01
	updateCost()

func doneButtonPressed():
	globals.player["shirt"] = shirtTab.get_node("ColorPicker").color
	globals.player["shorts"] = shortsTab.get_node("ColorPicker").color
	globals.player["shoes"] = shoesTab.get_node("ColorPicker").color

	globals.money -= cost

	var name = get_node("KitTabContainer/Name/LineEdit").get_text()
	if not name.empty():
		globals.player["name"] = name

	emit_signal("done")

func cancelButtonPressed():
	emit_signal("cancel")

func nameChanged( text ):
	var test = get_node("KitTabContainer/Name/Test")
	test.set_text(text)
	test.set_size(Vector2(0, 0))

	if test.get_size().width >= 400:
		get_node("KitTabContainer/Name/LineEdit").set_text(text.substr(0, text.length() - 1))
		get_node("KitTabContainer/Name/LineEdit").set_cursor_pos(text.length())
