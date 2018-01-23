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

func _ready():
	player = get_node("Player")

	shirtTab = get_node("KitTabContainer/Shirt")
	shortsTab = get_node("KitTabContainer/Shorts")
	shoesTab = get_node("KitTabContainer/Shoes")

	doneButton = get_node("DoneButton")

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

	if cost > Globals.get("money"):
		doneButton.set_disabled(true)

func setup():
	shirtTab.get_node("ColorPicker").setColor(Globals.get("player/shirt"))
	shortsTab.get_node("ColorPicker").setColor(Globals.get("player/shorts"))
	shoesTab.get_node("ColorPicker").setColor(Globals.get("player/shoes"))

	changedShirt = false
	changedShorts = false
	changedShoes = false

	player.setKit(Globals.get("player/shirt"), Globals.get("player/shorts"), Globals.get("player/shoes"))
	player.setSkin(Globals.get("player/skin"))
	player.setHair(Globals.get("player/hair"), Globals.get("player/hairColor"))

	get_node("KitTabContainer/Name/LineEdit").set_text(Globals.get("player/name"))

	doneButton.set_disabled(false)

	updateCost()

func shirtColorChanged(color):
	player.setKit(color, null, null)

	var c = Globals.get("player/shirt")
	changedShirt = abs(color.r - c.r) >= 0.01 or abs(color.g - c.g) >= 0.01 or abs(color.b - c.b) >= 0.01
	#changedShirt = color != Globals.get("player/shirt")
	updateCost()

func shortsColorChanged(color):
	player.setKit(null, color, null)

	var c = Globals.get("player/shorts")
	changedShorts = abs(color.r - c.r) < 0.01 or abs(color.g - c.g) < 0.01 or abs(color.b - c.b) < 0.01
	#changedShorts = color != Globals.get("player/shorts")
	updateCost()

func shoesColorChanged(color):
	player.setKit(null, null, color)

	var c = Globals.get("player/shoes")
	changedShoes = abs(color.r - c.r) < 0.01 or abs(color.g - c.g) < 0.01 or abs(color.b - c.b) < 0.01
	#changedShoes = color != Globals.get("player/shoes")
	updateCost()

func doneButtonPressed():
	Globals.set("player/shirt", shirtTab.get_node("ColorPicker").color)
	Globals.set("player/shorts", shortsTab.get_node("ColorPicker").color)
	Globals.set("player/shoes", shoesTab.get_node("ColorPicker").color)

	Globals.set("money", Globals.get("money") - cost)

	var name = get_node("KitTabContainer/Name/LineEdit").get_text()
	if not name.empty():
		Globals.set("player/name", name)

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
