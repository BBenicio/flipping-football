extends Label

export var timeout = 1.0

var timer = null
var last = 0

func _ready():
	timer = get_node("Timer")
	timer.set_wait_time(timeout)

	tick()

func tick():
	var fps = OS.get_frames_per_second()
	if fps != last:
		set_text(str(fps))
		last = fps