extends StateMachine

func _ready() -> void:
	add_state("idle")
	add_state("attack")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", "fall")


func _state_logic(delta : float) -> void:
	match state:
		states.idle:
			pass
		states.attack:
			pass
		states.walk:
			parent.move()
			parent.apply_fall_gravity(delta)
			parent.set_facing()
		states.jump:
			parent.move()
			parent.apply_jump_gravity(delta)
		states.fall:
			if Input.is_action_just_pressed("jump"):
				parent.jump_buffer_timer.start(0.1)
			parent.move()
			parent.apply_fall_gravity(delta)


func _get_transition(delta : float):
	match state:
		states.idle:
			if Input.is_action_just_pressed("jump") or not parent.jump_buffer_timer.is_stopped():
				return states.jump
			if parent.get_x_input() != 0:
				return states.walk
			if Input.is_action_just_pressed("interact") and parent.can_attack:
				return states.attack
		states.attack:
			pass
		states.walk:
			if parent.get_x_input() == 0:
				return states.idle
			if Input.is_action_just_pressed("jump"):
				return states.jump
			if not parent.is_on_floor():
				return states.fall
			if Input.is_action_just_pressed("interact") and parent.can_attack:
				return states.attack
		states.jump:
			if parent.velocity.y > 0:
				return states.fall
		states.fall:
			if not parent.coyote_timer.is_stopped() and Input.is_action_just_pressed("jump"):
				return states.jump
			if parent.is_on_floor():
				return states.idle
	return null


func _enter_state(new_state, old_state) -> void:
	match new_state:
		states.idle:
			if old_state == states.fall:
				parent.set_v_drag_margin(true)
			parent.anim_sprite.play("idle")
		states.attack:
			parent.anim_sprite.play("attack")
		states.walk:
			parent.anim_sprite.play("walk")
		states.jump:
			parent.set_v_drag_margin(false)
			parent.jump_sfx.play()
			parent.jump()
			parent.anim_sprite.play("jump")
		states.fall:
			if old_state == states.walk:
				parent.coyote_timer.start(0.1)
				parent.set_v_drag_margin(false)
			parent.anim_sprite.play("fall")


func _exit_state(old_state, new_state) -> void:
	match old_state:
		states.idle:
			pass
		states.attack:
			pass
		states.walk:
			pass
		states.jump:
			pass
		states.fall:
			parent.land_sfx.play()
