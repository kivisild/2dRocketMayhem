extends CharacterBody2D

const MAX_RUN_SPEED           = 200.0
const RUN_ACCEL = 1200.0
const MAX_TOTAL_SPEED = 1200
const JUMP_VELOCITY   = -400.0
const MAX_JUMPS       = 2
const BLAST_DECAY     = 2_000.0       # pixels / s² of “air-friction” on the knock-back
const GROUND_FRICTION = 1_200.0       # pixels / s² when no input



var current_jumps  : int       = 0
var jumping        : bool      = false
var was_on_floor   : bool      = false
var blast_impulse  : Vector2   = Vector2.ZERO   # one-off knock-back that fades out


@onready var jump_leeway_timer : Timer           = $JumpLeewayTimer
@onready var anim               : AnimationPlayer = $AnimationPlayer
@onready var rocket_scene       : PackedScene     = preload("res://rocket.tscn")

func _physics_process(delta: float) -> void:
	# 1. ─── START WITH GRAVITY ───────────────────────────────
	if !is_on_floor():
		velocity += get_gravity() * delta

	# 2. ─── READ HORIZONTAL INPUT INTO local var `input_vx` ─
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		
		velocity.x = move_toward(velocity.x, dir * MAX_RUN_SPEED, RUN_ACCEL * delta)
		$AnimatedSprite2D.flip_h = dir < 0
		if velocity.y == 0:
			anim.play("Run")
	else:
		# natural ground friction when no keys are pressed
		velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)
		if velocity.y == 0:
			anim.play("Idle")
			

	# 3. ─── JUMP ─────────────────────────────────────────────
	if (Input.is_action_just_pressed("ui_accept") \
		or Input.is_action_just_pressed("ui_up")) \
		and (current_jumps < MAX_JUMPS \
			 or (!jump_leeway_timer.is_stopped() and !jumping)):
		velocity.y = JUMP_VELOCITY
		jumping = true
		current_jumps += 1
		anim.play("Jump")

	# 4. ─── COMBINE INPUT + BLAST, THEN MOVE ────────────────
	velocity += blast_impulse
	velocity.x = clamp(velocity.x, -MAX_TOTAL_SPEED, MAX_TOTAL_SPEED)


	move_and_slide()

	# 5. ─── FADE OUT THE IMPULSE AFTER WE MOVE ─────────────
	blast_impulse = blast_impulse.move_toward(
		Vector2.ZERO, BLAST_DECAY * delta)

	# 6. ─── LANDING RESET ──────────────────────────────────
	if is_on_floor() and !was_on_floor:
		current_jumps = 0
		jumping = false
	was_on_floor = is_on_floor()

	# 7. ─── SPAWN ROCKET ───────────────────────────────────
	if Input.is_action_just_pressed("click"):
		var r := rocket_scene.instantiate()
		r.global_position = global_position
		var aim_dir : Vector2= (get_global_mouse_position() - r.global_position).normalized()
		r.rotation  = aim_dir.angle() + PI / 2
		r.velocity  = aim_dir * r.speed
		r.connect("exploded", Callable(self, "_on_rocket_exploded"))
		get_tree().current_scene.add_child(r)
		for slime in get_tree().get_nodes_in_group("Slime"):
			r.connect("exploded", Callable(slime, "_on_rocket_exploded"))

# ───────────────────────────
#  ROCKET BLAST CALLBACK
func _on_rocket_exploded(explosion_pos: Vector2) -> void:
	const MAX_RADIUS := 100.0
	const STRENGTH   := 300.0

	var to_player := global_position - explosion_pos
	var distance  := to_player.length()
	if distance > MAX_RADIUS:
		return                                    # out of range

	var t = distance / MAX_RADIUS        # 0 → 1
	var falloff = pow(1.0 - t, 0.6)
	blast_impulse = to_player.normalized() * STRENGTH * falloff
	blast_impulse.x *= 1.25
	blast_impulse.y *= 0.7
	current_jumps = 1
	
