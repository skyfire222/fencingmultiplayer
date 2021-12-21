extends PlayerState



func enter(_msg := {}) -> void:
	pass


func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("key_dash"):
		state_machine.transition_to("Dash")
	var mydirection:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("key_left"):
		mydirection += Vector2(-1,0)
	if Input.is_action_pressed("key_right"):
		mydirection += Vector2(1,0)
	if !Input.is_action_pressed("key_left") and !Input.is_action_pressed("key_right"):
		var damp_speed = clamp(player.decelerate_speed,0, abs(player.velocity.x))
		player.velocity.x -= damp_speed * sign(player.velocity.x)
	
	if !player.is_on_floor():
		player.velocity.y += player.gravity.y
	else: 
		if Input.is_action_pressed("key_up") and player.velocity.y > 0:
			player.velocity.y = -player.jump_strength
		else:
			player.velocity.y = player.gravity.y 

	player.velocity.x += mydirection.x * player.speed # consistent jump height regardless of "speed" variable
	player.velocity.x = clamp(player.velocity.x, -player.max_speed, player.max_speed)
	player.move_and_slide(player.velocity, player.up_direction)
	
