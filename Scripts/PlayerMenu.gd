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

	distanceRange.set_max(5)
	heightRange.set_max(5)
	speedRange.set_max(5)

	setup()

func setup():
	skinColorPicker.setColor(Globals.get("player/skin"))
	hairColorPicker.setColor(Globals.get("player/hairColor"))
	hairStyleOption.select(Globals.get("player/hair"))

	distanceRange.set_value(Globals.get("player/distance"))
	heightRange.set_value(Globals.get("player/height"))
	speedRange.set_value(Globals.get("player/speed"))

	if Globals.get("money") < 100:
		distanceRange.set_disabled(true)
		heightRange.set_disabled(true)
		speedRange.set_disabled(true)

	hairStyleOption.select(Globals.get("player/hair"))
	hairColorPicker.setColor(Globals.get("player/hairColor"))
	skinColorPicker.setColor(Globals.get("player/skin"))

	player.setKit(Globals.get("player/shirt"), Globals.get("player/shorts"), Globals.get("player/shoes"))
	player.setHair(Globals.get("player/hair"), Globals.get("player/hairColor"))

	distanceRange.set_value(Globals.get("player/distance"))
	heightRange.set_value(Globals.get("player/height"))
	speedRange.set_value(Globals.get("player/speed"))

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

	doneButton.set_disabled(cost > Globals.get("money"))

func styleOptionButtonItemSelected(id):
	player.setHair(id, null)

	changeHairStyle = id != Globals.get("player/hair")
	updateCost()

func hairColorChanged( color ):
	player.setHair(null, color)

	var c = Globals.get("player/hairColor")
	changeHairColor = abs(color.r - c.r) < 0.01 or abs(color.g - c.g) < 0.01 or abs(color.b - c.b) < 0.01
	#changeHairColor = color != Globals.get("player/hairColor")
	updateCost()

func skinColorChanged( color ):
	player.setSkin(color)

	var c = Globals.get("player/skin")
	changeSkin = abs(color.r - c.r) < 0.01 or abs(color.g - c.g) < 0.01 or abs(color.b - c.b) < 0.01
	#changeSkin = color != Globals.get("player/skin")
	updateCost()

func distanceRangeValueChanged( value ):
	changeDistance = value - Globals.get("player/distance")
	updateCost()

func heightRangeValueChanged( value ):
	changeHeight = value - Globals.get("player/height")
	updateCost()

func speedRangeValueChanged( value ):
	changeSpeed = value - Globals.get("player/speed")
	updateCost()

func doneButtonPressed():
	Globals.set("player/hair", hairStyleOption.get_selected_ID())
	Globals.set("player/hairColor", hairColorPicker.color)
	Globals.set("player/skin", skinColorPicker.color)

	Globals.set("player/distance", distanceRange.get_value())
	Globals.set("player/height", heightRange.get_value())
	Globals.set("player/speed", speedRange.get_value())

	Globals.set("money", Globals.get("money") - cost)

	emit_signal("done")

func cancelButtonPressed():
	emit_signal("cancel")

func resetButtonPressed():
	get_node("ResetDialog").popup()

func resetDialogConfirmed():
	Globals.set("player/distance", 0)
	Globals.set("player/height", 0)
	Globals.set("player/speed", 0)

	distanceRange.set_value(0)
	heightRange.set_value(0)
	speedRange.set_value(0)

	changeDistance = 0
	changeHeight = 0
	changeSpeed = 0

	updateCost()