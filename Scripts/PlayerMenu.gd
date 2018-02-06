extends Control

signal cancel
signal done

const UPGRADE_COST = 100
const CHANGE_COST = 10

var player = null

var skinColorPicker = null
var hairColorPicker = null
var hairStyleOption = null

var distanceRange = null
var heightRange = null
var speedRange = null

var doneButton = null

var globals = null

var changeSkin = false
var changeHairStyle = false
var changeHairColor = false
var changeDistance = 0
var changeHeight = 0
var changeSpeed = 0

var cost = 0

func _ready():
	hairStyleOption = get_node("PlayerTabContainer/Hair/Panel/StyleOptionButton")
	for i in range(8):
		hairStyleOption.add_item(str(i + 1), i)

	player = get_node("Player")
	skinColorPicker = get_node("PlayerTabContainer/Skin/ColorPicker")
	hairColorPicker = get_node("PlayerTabContainer/Hair/ColorPicker")
	hairStyleOption = get_node("PlayerTabContainer/Hair/Panel/StyleOptionButton")

	distanceRange = get_node("PlayerTabContainer/Upgrade/DistanceRange")
	heightRange = get_node("PlayerTabContainer/Upgrade/HeightRange")
	speedRange = get_node("PlayerTabContainer/Upgrade/SpeedRange")

	doneButton = get_node("DoneButton")

	globals = get_node("/root/GlobalHack")

	distanceRange.set_max(5)
	heightRange.set_max(5)
	speedRange.set_max(5)

	setup()

func setup():
	skinColorPicker.setColor(globals.player["skin"])
	hairColorPicker.setColor(globals.player["hairColor"])
	hairStyleOption.select(globals.player["hair"])

	distanceRange.set_value(globals.player["distance"])
	heightRange.set_value(globals.player["height"])
	speedRange.set_value(globals.player["speed"])

	if globals.money < 100:
		distanceRange.set_disabled(true)
		heightRange.set_disabled(true)
		speedRange.set_disabled(true)

	player.setKit(globals.player["shirt"], globals.player["shorts"], globals.player["shoes"])
	player.setSkin(globals.player["skin"])
	player.setHair(globals.player["hair"], globals.player["hairColor"])

	distanceRange.set_value(globals.player["distance"])
	heightRange.set_value(globals.player["height"])
	speedRange.set_value(globals.player["speed"])

	changeDistance = 0
	changeHeight = 0
	changeSpeed = 0
	changeSkin = false
	changeHairStyle = false
	changeHairColor = false

	updateCost()

func updateCost():
	cost = UPGRADE_COST * (changeDistance + changeHeight + changeSpeed)

	if changeSkin: cost += CHANGE_COST
	if changeHairStyle: cost += CHANGE_COST
	if changeHairColor: cost += CHANGE_COST

	if cost > 0:
		doneButton.set_text("Done ($ " + str(cost) + ")")
	else:
		doneButton.set_text("Done")

	doneButton.set_disabled(cost > globals.money)

func styleOptionButtonItemSelected(id):
	player.setHair(id, null)

	changeHairStyle = id != globals.player["hair"]
	updateCost()

func hairColorChanged( color ):
	player.setHair(null, color)

	var c = globals.player["hairColor"]
	changeHairColor = abs(color.r - c.r) > 0.01 or abs(color.g - c.g) > 0.01 or abs(color.b - c.b) > 0.01
	updateCost()

func skinColorChanged( color ):
	player.setSkin(color)

	var c = globals.player["skin"]
	changeSkin = abs(color.r - c.r) > 0.01 or abs(color.g - c.g) > 0.01 or abs(color.b - c.b) > 0.01
	updateCost()

func distanceRangeValueChanged( value ):
	changeDistance = value - globals.player["distance"]
	updateCost()

func heightRangeValueChanged( value ):
	changeHeight = value - globals.player["height"]
	updateCost()

func speedRangeValueChanged( value ):
	changeSpeed = value - globals.player["speed"]
	updateCost()

func doneButtonPressed():
	globals.player["hair"] = hairStyleOption.get_selected_ID()
	globals.player["hairColor"] = hairColorPicker.color
	globals.player["skin"] = skinColorPicker.color

	globals.player["distance"] = distanceRange.get_value()
	globals.player["height"] = heightRange.get_value()
	globals.player["speed"] = speedRange.get_value()

	globals.money -= cost

	emit_signal("done")

func cancelButtonPressed():
	emit_signal("cancel")

func resetButtonPressed():
	get_node("ResetDialog").popup()

func resetDialogConfirmed():
	globals.player["distance"] = 0
	globals.player["height"] = 0
	globals.player["speed"] = 0

	distanceRange.set_value(0)
	heightRange.set_value(0)
	speedRange.set_value(0)

	changeDistance = 0
	changeHeight = 0
	changeSpeed = 0

	updateCost()