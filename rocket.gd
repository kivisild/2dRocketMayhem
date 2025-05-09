extends Area2D


var speed = 750
@export var velocity: Vector2
signal exploded(global_pos: Vector2)

func _physics_process(delta):
		position += velocity * delta
		


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("Explode")
		emit_signal("exploded", global_position)
		

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
