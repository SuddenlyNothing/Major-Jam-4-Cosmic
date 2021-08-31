extends Camera2D

const LOOK_AHEAD_FACTOR = 0.01

onready var t := $Tween

var facing = 0

onready var prev_camera_pos = get_camera_position()

func _process(_delta):
	_check_facing()
	prev_camera_pos = get_camera_position()

func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x)
	if new_facing != 0 and facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
		
		t.interpolate_property(self, "position:x", position.x, target_offset, 1.0,
			Tween.TRANS_SINE, Tween.EASE_OUT)
		t.start()
