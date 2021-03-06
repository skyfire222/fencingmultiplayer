extends PlayerState

var spearscene = preload("res://Spear/Spear.tscn")


func enter(_msg := {}) -> void:
	
	pass

var spear_position = Vector2(0,0)
func physics_update(_delta: float) -> void:
	# change states conditions
	if Input.is_action_just_pressed("key_dash"):
		state_machine.transition_to("Dash")

	# get left right input
	var mydirection:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("key_left"):
		mydirection += Vector2(-1,0)
	if Input.is_action_pressed("key_right"):
		mydirection += Vector2(1,0)
	# stop moving left or right if player stops pressing those keys
	if !Input.is_action_pressed("key_left") and !Input.is_action_pressed("key_right"):
		var damp_speed = clamp(player.decelerate_speed,0, abs(player.velocity.x)) # calculate magnitude of deceleration
		player.velocity.x -= damp_speed * sign(player.velocity.x) # magnitude times direction = acceleration, then add acceleration to velocity
	
	
	
	
	# up down input
	if !player.is_on_floor(): # if falling
		player.velocity.y += player.gravity.y # fall
	else: 
		if Input.is_action_pressed("key_up"): # if on floor, and want to jump 
			player.velocity.y = -player.jump_strength
		else:
			player.velocity.y = player.gravity.y  # else feel gravity pressure into floor

	player.velocity.x += mydirection.x * player.speed # consistent jump height regardless of "speed" variable (used to be all of velocity multiplied by speed)
	player.velocity.x = clamp(player.velocity.x, -player.max_speed, player.max_speed) # ensure max left right speed
	
	# apply velocity
	player.move_and_slide(player.velocity, player.up_direction)
	
	if player.get_node_or_null("Spear") != null:
		var new_spear_position = (player.get_global_mouse_position() - player.global_position).normalized() * 7
		new_spear_position.y += 4
		player.get_node("Spear").position = lerp(player.get_node("Spear").position, new_spear_position, 0.1)
	else:
		var new_spear_position = (player.get_global_mouse_position() - player.global_position).normalized() * 3
		new_spear_position.y += 4
		player.get_node("nose2").position = lerp(player.get_node("nose2").position, Vector2(5,-2) + new_spear_position, 0.1)
	
	
	
	if (Input.is_action_pressed("key_throw")) and player.get_node_or_null("Spear") != null:
		if !(player.get_node("Timer").time_left > 0):
			var myspear = spearscene.instance()
			myspear.position = player.position
			myspear.velocity = (player.get_global_mouse_position() - player.position).normalized() * player.throw_power
			myspear.thrown = true
			myspear.rotation = player.get_node("Spear").rotation 
			myspear.global_position = player.get_node("Spear").global_position
			get_tree().root.add_child(myspear)
			player.get_node("Spear").queue_free()
			player.get_node("Timer").start()
		
	elif Input.is_action_pressed("key_throw"):
		for thrown_spear in player.get_node("pickuprange").get_overlapping_bodies():
			if (player.get_node_or_null("Spear") == null) and thrown_spear.collided and !(player.get_node("Timer").time_left > 0):
				thrown_spear.queue_free()
				var myspear = spearscene.instance()
				myspear.name = "Spear"
				myspear.thrown = false
				player.add_child(myspear)
				player.get_node("Timer").start()
