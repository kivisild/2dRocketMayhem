extends CharacterBody2D

var player
var chase := false
const SPEED = 50
const JUMP_FORCE = 250
var on_ground := false
var dead := false

func _ready() -> void:
	add_to_group("Slime")

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	on_ground = is_on_floor()
	if dead:
		return
	if chase == true:
		get_node("AnimatedSprite2D").play("Jump")
		if is_on_floor():
			if not on_ground:
				
				get_node("AnimatedSprite2D").play("Land")
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
	
func _on_rocket_exploded(explosion_pos: Vector2) -> void:
	print("exploded")
	const MAX_RADIUS := 100.0
	const STRENGTH   := 300.0

	var to_slime := global_position - explosion_pos
	var distance  := to_slime.length()
	if distance < MAX_RADIUS:
		dead = true
		get_node("AnimatedSprite2D").play("DeathExplode")
		await get_node("AnimatedSprite2D").animation_finished
		queue_free()                                    # out of range

	
