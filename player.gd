extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const max_jumps = 2

var currentJumps = 0
var jumping = false
var was_on_floor = false;

@onready var jump_leeway_timer = $JumpLeewayTimer
@onready var anim = get_node("AnimationPlayer")



func _physics_process(delta: float) -> void:
	was_on_floor = is_on_floor()
	
		
	if (was_on_floor and !is_on_floor()):
		jump_leeway_timer.start()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	
	

	# Handle jump.
	# Coyote time
	if ((Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and currentJumps < max_jumps) or ((Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and !jump_leeway_timer.is_stopped() and !jumping):
		velocity.y = JUMP_VELOCITY
		jumping = true
		currentJumps += 1
		anim.play("Jump")
		print("Jumping")
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("Idle")
			
	#if velocity.y > 0:
		#anim.play("Fall")

	move_and_slide()
	if (is_on_floor() and !was_on_floor):
			# Landed
			currentJumps = 0
			jumping = false
			print("Landed - Is on floor and was not on floor")
			
		


func _on_jump_leeway_timer_timeout() -> void:
	pass
