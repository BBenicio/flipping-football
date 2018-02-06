extends RigidBody2D

export var cosmetic = false
export var soundInterval = 0.2

var globals = null
var hitPlayer = null

var lastPlayed = 0

func _ready():
	globals = get_node("/root/GlobalHack")

	hitPlayer = get_node("Hit")

	if not cosmetic:
		connect("body_enter", self, "bodyEnter")
		set_process(true)

func _process(delta):
	lastPlayed += delta

func bodyEnter(body):
	if lastPlayed > soundInterval:
		hitPlayer.set_default_volume(globals.settings["soundVolume"])
		hitPlayer.play("ball")
		lastPlayed = 0
