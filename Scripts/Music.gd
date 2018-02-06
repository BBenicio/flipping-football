extends Node

var current = 0
var total = 0
var globals = null

func _ready():
	total = get_child_count()

	globals = get_node("/root/GlobalHack")

	set_process(true)

func _process(delta):
	get_child(current).set_volume(globals.settings["musicVolume"])

func pause():
	get_child(current).set_paused(true)

func stop():
	get_child(current).stop()

func play():
	var currentNode = get_child(current)
	if currentNode.is_paused():
		currentNode.set_paused(false)
	elif not currentNode.is_playing():
		currentNode.play()