extends CharacterBody2D

var player
var chase := false
const SPEED = 50
const JUMP_FORCE = 250
var on_ground := false
var dead := false

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	on_ground = is_on_floor()
	if dead:
		return
	if chase == true:
		get_node("AnimatedSprite2D").play("Jump")
		print("Playing Jump")
		if is_on_floor():
			if not on_ground:
				
				get_node("AnimatedSprite2D").play("Land")
				print("Playing land")
			on_ground = true
		player = get_node("../../Player/Player")
		var direction = (player.position- self.position).normalized()
		if direction.x > 0:
			get_node("AnimatedSprite2D").flip_h = true
			
		else:
			get_node("AnimatedSprite2D").flip_h = false
			
		velocity.x = direction.x * SPEED
	else:
		velocity.x = 0
		
		get_node("AnimatedSprite2D").play("Idle")
		print("Playing idle")
		
	if chase and on_ground:
		velocity.y = -JUMP_FORCE
		get_node("AnimatedSprite2D").play("Jump")
		on_ground = false
	move_and_slide()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false


func _on_jump_kill_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	dead = true
	get_node("AnimatedSprite2D").play("DeathJump")
	print("Playing DeathJump")
	$CollisionShape2D.disabled = true    # stop further hits
	velocity = Vector2.ZERO              # freeze motion
	await get_node("AnimatedSprite2D").animation_finished
	queue_free()
	
r.connect("exploded", Callable(self, "_on_rocket_exploded"))
