extends KinematicBody2D

var move_speed = 200.0

var velocity := Vector2.ZERO

var jump_height : float = 150.0
var jump_time_to_peak : float = 0.4
var jump_time_to_descent : float = 0.6

var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var coyote_timer := $CoyoteTimer
onready var jump_buffer_timer := $JumpBufferTimer
onready var anim_sprite := $Flip/AnimatedSprite
onready var flip := $Flip
onready var interact := $Interact
onready var state_label := $StateLabel
onready var player_states := $PlayerStates
onready var tool_pos := $Flip/AnimatedSprite/ToolPos
onready var thought_tween := $Thought/Tween
onready var thought := $Thought
onready var camera := $Camera2D
onready var tool_sprite := $Flip/AnimatedSprite/ToolPos/ToolSprite

onready var step_sfx := $StepSFX
onready var land_sfx := $LandSFX
onready var jump_sfx := $JumpSFX
onready var attack_sfx := $AttackSFX

var tool_group : String = ""
var CurrentTool : PackedScene

var is_on_floor
var can_attack := true

func _ready() -> void:
	anim_sprite.play("idle")


func _process(delta : float) -> void:
	state_label.text = player_states.state
	set_tool_pos()


func apply_fall_gravity(delta : float) -> void:
	velocity.y += fall_gravity * delta


func apply_jump_gravity(delta : float) -> void:
	velocity.y += jump_gravity * delta


func jump():
	velocity.y = jump_velocity


func get_x_input() -> float:
	var x_dir := 0.0
	
	if Input.is_action_pressed("move_left"):
		x_dir -= 1.0
	if Input.is_action_pressed("move_right"):
		x_dir += 1.0
	
	return x_dir


func move():
	velocity.x = get_x_input() * move_speed
	velocity = move_and_slide(velocity, Vector2.UP)


func set_anim() -> void:
	var x_dir = get_x_input()
	if not is_on_floor():
		if velocity.y > 0:
			anim_sprite.play("fall")
		else:
			anim_sprite.play("jump")
	elif x_dir == 0:
		anim_sprite.play("idle")
	elif x_dir != 0:
		anim_sprite.play("walk")


func set_facing() -> void:
	var x_dir = get_x_input()
	if flip.scale.x > 0 and x_dir < 0:
		flip.scale.x *= -1
	if flip.scale.x < 0 and x_dir > 0:
		flip.scale.x *= -1


func set_tool_pos():
	match anim_sprite.animation:
		"attack":
			match anim_sprite.frame:
				0:
					tool_pos.position = Vector2(-17, -4)
					tool_pos.rotation_degrees = -45
				1:
					attack_sfx.play()
					tool_pos.position = Vector2(12, -4)
					tool_pos.rotation_degrees = 45
		"fall":
			tool_pos.rotation_degrees = -45
			match anim_sprite.frame:
				0:
					tool_pos.position = Vector2(-15, -7)
				1:
					tool_pos.position = Vector2(-15.5, -5)
		"idle":
			tool_pos.rotation_degrees = 180
			match anim_sprite.frame:
				0:
					tool_pos.position = Vector2(-4.5, 7.5)
				1:
					tool_pos.position = Vector2(-4.5, 7.5)
				2:
					tool_pos.position = Vector2(-5.5, 8.5)
		"jump":
			match anim_sprite.frame:
				0:
					tool_pos.rotation_degrees = 180
					tool_pos.position = Vector2(-6.5, 7.5)
				1:
					tool_pos.rotation_degrees = 270
					tool_pos.position = Vector2(-13, 5)
				2:
					tool_pos.rotation_degrees = -112.5
					tool_pos.position = Vector2(-17, 0)
		"walk":
			match anim_sprite.frame:
				0:
					tool_pos.rotation_degrees = 135
					tool_pos.position = Vector2(0.5, 5.5)
				1:
					step_sfx.play()
					tool_pos.rotation_degrees = 180
					tool_pos.position = Vector2(-4.5, 7.5)
				2:
					tool_pos.rotation_degrees = 135
					tool_pos.position = Vector2(-6.5, 5.5)
				3:
					step_sfx.play()
					tool_pos.rotation_degrees = 180
					tool_pos.position = Vector2(-4.5, 7.5)


func _on_AnimatedSprite_animation_finished():
	if anim_sprite.animation == "attack":
		player_states.call_deferred("set_state", "idle")


func say(dialog : String) -> void:
	thought.modulate.a = 1
	thought.rect_size = Vector2()
	thought.text = dialog
	yield(get_tree(), "idle_frame")
	thought.rect_position.x = -thought.rect_size.x / 2
	thought.percent_visible = 0
	var text_duration := len(dialog) / 30.0
	thought_tween.interpolate_property(thought, "percent_visible", 0, 1, text_duration)
	thought_tween.interpolate_property(thought, "modulate:a",
		1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, text_duration * 2)
	thought_tween.start()


func set_v_drag_margin(is_grounded : bool) -> void:
	camera.drag_margin_v_enabled = !is_grounded


func interact() -> void:
	var areas = interact.get_overlapping_areas()
	var min_dist
	var nearest_area
	for area in areas:
		if min_dist == null or position.distance_to(area.position) < min_dist:
			min_dist = area
			nearest_area = area
	if nearest_area.is_in_group("pickable"):
		if CurrentTool != null:
			var previous_tool = CurrentTool.instance()
			CurrentTool.position = position
		CurrentTool = load(nearest_area.filename)
		var tool_info = nearest_area.get_info()
		tool_group = tool_info.group
		tool_sprite.texture = tool_info.texture
	else:
		player_states.call_deferred("set_state", "attack")
