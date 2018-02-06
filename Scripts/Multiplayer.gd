extends Node

const PORT = 7128

var packetPeer = PacketPeerUDP.new()

var globals = null

export var timeout = 5
export var interval = 1

var ip = null
var trying = false
var counter = 0
var timeoutCounter = 0

var tween = null
var notification = null
var moneyLabel = null

func encodeIP(ip):
	var encoded = ""
	for cell in ip.split("."):
		var c = int(cell)
		var div = c / 26 + "a".ord_at(0)
		var rem = c % 26 + "a".ord_at(0)

		var arr = RawArray()
		arr.append(div)
		arr.append(rem)

		encoded += arr.get_string_from_ascii()

	return encoded

func decodeIP(encoded):
	var array = []
	for i in range(0, encoded.length(), 2):
		var div = encoded.ord_at(i) - "a".ord_at(0)
		var rem = encoded.ord_at(i + 1) - "a".ord_at(0)

		array.append(26 * div + rem)

	var ip = ""
	for i in range(array.size()):
		ip += str(array[i])
		if i < 3:
			ip += "."

	return ip

func _ready():
	var allIps = IP.get_local_addresses()
	for i in allIps:
		var asArray = i.split(".")
		if asArray.size() != 4:
			continue

		var first = int(asArray[0])
		var second = int(asArray[1])

		if first == 10 or (first == 172 and second >= 16 and second <= 31) or (first == 192 and second == 168):
			ip = i
			print("Found ", ip)
			#break

	print("Using ", ip)

	globals = get_node("/root/GlobalHack")

	get_node("Menu/Code Panel/Code").set_text(encodeIP(ip))

	packetPeer.listen(PORT)

	tween = get_node("Menu/Tween")
	notification = get_node("Notification")
	moneyLabel = get_node("Money")

	tween.interpolate_property(get_node("Menu"), "rect/pos", Vector2(1920, 0), Vector2(0, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

	if Globals.has("match/result") and not Globals.get("match/prizeGiven"):
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

		if Globals.get("multiplayer/timeout"):
			prize /= 2
			text += ". Your prize was halved because the match did not finish"
			notification.time = 5

		notification.set_text("You earned $ " + str(prize) + text)
		notification.pop()

		globals.money += prize

		Globals.set("match/prizeGiven", true)
	moneyLabel.set_text("$ " + str(globals.money))

	set_fixed_process(true)

func _fixed_process(delta):
	if trying:
		timeoutCounter += delta
		counter += delta

		if timeoutCounter >= timeout:
			print("Timeout, giving up")

			timeoutCounter = 0
			counter = 0
			trying = false

			get_node("Menu/Join Panel/JoinButton").set_disabled(false)
			get_node("Menu/MenuButton").set_disabled(false)
		elif counter >= interval:
			counter = 0
			print(".")
			packetPeer.put_var(0)

	var join = packetPeer.get_var()
	if join != null and join == 0 and not trying:
		var ip = packetPeer.get_packet_ip()
		packetPeer.set_send_address(ip, PORT)
		packetPeer.put_var(1)

		Globals.set("multiplayer/ip", ip)
		Globals.set("multiplayer/host", true)
		print(ip, " as HOST")

		get_tree().change_scene("res://Screens/MultiplayerMatch.tscn")
	elif join != null and join == 1:
		var ip = packetPeer.get_packet_ip()

		Globals.set("multiplayer/ip", ip)
		Globals.set("multiplayer/host", false)

		print(ip, " as CLIENT")
		get_tree().change_scene("res://Screens/MultiplayerMatch.tscn")
	elif join != null:
		print("> ", join)

func joinButtonPressed():
	var ip = decodeIP(get_node("Menu/Join Panel/Code").get_text())

	if not ip.is_valid_ip_address():
		print(ip, " is not a valid ip")
		trying = false
		return

	packetPeer.set_send_address(ip, PORT)
	packetPeer.put_var(0)
	trying = true

	get_node("Menu/Join Panel/JoinButton").set_disabled(true)
	get_node("Menu/MenuButton").set_disabled(true)

func menuButtonPressed():
	packetPeer.close()

	tween.interpolate_property(get_node("Menu"), "rect/pos", Vector2(0, 0), Vector2(1920, 0), 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.connect("tween_complete", self, "menu")
	tween.start()

func menu(a, b):
	get_tree().change_scene("res://Screens/Menu.tscn")

func codeTextChanged( text ):
	var c = get_node("Menu/Join Panel/Code")
	var pos = c.get_cursor_pos()
	c.set_text(text.to_lower())
	c.set_cursor_pos(pos)
