extends ParallaxBackground

var motion_velocity := Vector2(0.1, 0.2)

onready var stars_light := $StarsLight
onready var stars_medium := $StarsMedium
onready var stars_bright := $StarsBright
onready var smoke := $Smoke
onready var purple_smoke := $PurpleSmoke
onready var galaxy := $Galaxy
onready var medium_stars := $MediumStars
onready var large_stars := $LargeStars
onready var planets := $Planets


func _process(delta):
	var speed = motion_velocity * delta
	stars_light.motion_offset += speed
	stars_medium.motion_offset -= speed * 0.9
	stars_bright.motion_offset += speed * 0.8
	galaxy.motion_offset += speed * 0.75
	medium_stars.motion_offset += speed * 0.75
	large_stars.motion_offset += speed * 0.7
	planets.motion_offset += speed * 0.65
	smoke.motion_offset += speed * 0.3
	purple_smoke.motion_offset += speed * 0.25
