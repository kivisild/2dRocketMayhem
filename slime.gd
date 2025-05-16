extends CharacterBody2D

var player
var chase = false
const SPEED = 50
var on_ground = false

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	on_ground = is_on_floor()
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
		
	move_and_slide()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
